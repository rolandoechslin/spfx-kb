
# source: https://techcommunity.microsoft.com/t5/microsoft-stream-forum/powershell-script-to-list-all-videos-in-your-365-stream/m-p/1752149
# reference: https://techcommunity.microsoft.com/t5/microsoft-stream-forum/powershell-script-to-audit-and-export-channel-content-details-of/m-p/354832
# goal of this script 
#- get list of all videos in stream for analysis
#- it takes about 20 minutes to do this for 500 stream videos.

#First 
# find out what your api source is
# go to the following URL in chrome as an admin of Stream https://web.microsoftstream.com/browse
# using Developer tools look at the "console" search for .api.microsoftstream to find out what is between https://  and     .api.microsoftstream in my case    https://aase-1.api.microsoftstream.com/api/

[string]$rootAPIlocation = "aase-1"  #<<<< Update this value to the one you find in the console view 
#[string]$rootAPIlocation = "uswe-1" 	# use this for Western US
#[string]$rootAPIlocation = "euno-1" 	# use this for the Europe North region

#enter where you on your computer you want the files to go
[string]$PowerShellScriptFolder = "C:\Temp\streamanalysis"  #<<<< Update this value
#json files will be saved into "VideosJSON" folder 
[string]$streamJSONfolder = Join-Path -Path $PowerShellScriptFolder -ChildPath "VideosJSON"  #<<<< Update this value if you want a different folder name

#>>> REMOVES all exiisting JSON files <<<<
#remove all JSON items in this folder
Remove-Item -path $streamJSONfolder\* -include *.json -Force -Recurse
#guess approx number of videos you think you have divide by 100 e.g. 9 = 900 videos
[int]$Loopnumber = 9   #<<<< Update this value

#put in your stream portal url
[string]$StreamPortal = "https://web.microsoftstream.com/?NoSignUpCheck=1"
#put in the url where you see all videos from in stream
[string]$StreamPortalVideoRoot = "https://web.microsoftstream.com/browse/" #$StreamPortalChannelRootForFindingVideos
[string]$StreamPortalVideoViewRoot= "https://web.microsoftstream.com/video/" # for watching a video

#this builds from the info you've put in a URL which will give back the JSON info about all your videos.
[string]$StreamAPIVideos100 = "https://$rootAPIlocation.api.microsoftstream.com/api/videos?NoSignUpCheck=1&`$top=100&`$orderby=publishedDate%20desc&`$expand=creator,events&`$filter=published%20and%20(state%20eq%20%27Completed%27%20or%20contentSource%20eq%20%27livestream%27)&adminmode=true&api-version=1.4-private&`$skip=0" #$StreamAPIVideos100

# use the following if you want to only see files that have privacymode eq 'organization' i.e. video is visible to EVERYONE in the organisation
#Thanks to Ryechz for this 
#
#   [string]$StreamAPIVideos100 = "https://$rootAPIlocation.api.microsoftstream.com/api/videos?NoSignUpCheck=1&`$top=100&`$orderby=publishedDate%20desc&`$expand=creator,events&`$filter=published%20and%20(state%20eq%20%27Completed%27%20or%20contentSource%20eq%20%27livestream%27)%20and%20privacymode%20eq%20%27organization%27%20&adminmode=true&api-version=1.4-private&`$skip=0"




[int]$skipCounter
[int]$skipCounterNext = $skipCounter+100
[string]$fileName = "jsonfor-$skipCounter-to-$skipCounterNext.json"

#next section creates the URLS you need to manually download the json from , it was too hard to figure out how to do this programatically with authentication.


Write-Host "      Starting Chrome Enter your credentials to load O365 Stream portal" -ForegroundColor Magenta
#Thanks Conrad Murray for this tip 
Start-Process -FilePath 'chrome.exe' -ArgumentList $StreamPortal
Read-Host -Prompt "Press Enter to continue ...."

Write-host " -----------------------------------------" -ForegroundColor Green
Write-host " --Copy and past each url into chrome-----" -ForegroundColor Green
Write-host " --save JSON output into $streamJSONfolder" -ForegroundColor Green


for($i=0;$i -lt $Loopnumber; $i++) {
	$skipCounter = $i*100
	if($skipCounter -eq 0) {
		write-host $StreamAPIVideos100
		Start-Process -FilePath 'chrome.exe' -ArgumentList $StreamAPIVideos100
	} else {
		write-host $StreamAPIVideos100.replace("skip=0","skip=$skipCounter")
		#following code opens browser tabs for each of the jsonfiles 
		#Thanks Conrad Murray for this tip 
		Start-Process -FilePath 'chrome.exe' -ArgumentList $StreamAPIVideos100.replace("skip=0","skip=$skipCounter")
				
	}
	
}

Write-host " --save each browser window showing JSON output into $streamJSONfolder" -ForegroundColor Green
Write-host " -----------------------------------------------------------------------------------" -ForegroundColor Green


Write-host " -----------------------------------------" -ForegroundColor Green
Read-Host -Prompt "Press Enter to continue ...."



Write-host " -----------------------------------------" -ForegroundColor Green
$JSONFiles = Get-ChildItem -Path $streamJSONfolder -Recurse -Include *.json
[int]$videoscounter = 0
$VideosjsonAggregateddata=@()
$data=@()

foreach($fileItem in $JSONFiles)
{
	Write-host " -----------------------------------------" -ForegroundColor Green
	Write-Host "     =====>>>> getting content of JSON File:", $fileItem, "- Path:", $fileItem.FullName -ForegroundColor Yellow
	$Videosjsondata = Get-Content -Raw -Path $fileItem.FullName | ConvertFrom-Json
	$VideosjsonAggregateddata += $Videosjsondata
	Write-host " -----------------------------------------" -ForegroundColor Green
	#Write-Host "     =====>>>> Channel JSON Raw data:", $Videosjsondata -ForegroundColor green
	#Read-Host -Prompt "Press Enter to continue ...."
}

	write-host "You have "  $VideosjsonAggregateddata.value.count " videos in Stream , using these selection criteria"

foreach($myVideo in $VideosjsonAggregateddata.value)
{

		$videoscounter += 1
		$datum = New-Object -TypeName PSObject
		Write-host "        -----------------------------------------" -ForegroundColor Green
		Write-Host "        =====>>>> Video (N°", $videoscounter ,") ID:", $myVideo.id -ForegroundColor green
		Write-Host "        =====>>>> Video Name:", $myVideo.name," created:", $myVideo.created,"- modified:", $myVideo.modified -ForegroundColor green
		Write-Host "        =====>>>> Video Metrics views:", $myVideo.metrics.views, "- comments:", $myVideo.metrics.comments -ForegroundColor Magenta
		Write-Host "        =====>>>> Video Creator Name: ", $myVideo.creator.name , " - Email:", $myVideo.creator.mail -ForegroundColor Magenta		
		Write-Host "        =====>>>> Video Description: ", $myVideo.description -ForegroundColor Magenta	

		$datum | Add-Member -MemberType NoteProperty -Name VideoID -Value $myVideo.id
		$datum | Add-Member -MemberType NoteProperty -Name VideoName -Value $myVideo.name
		$datum | Add-Member -MemberType NoteProperty -Name VideoURL -Value $($StreamPortalVideoViewRoot + $myVideo.id)
		$datum | Add-Member -MemberType NoteProperty -Name VideoCreatorName -Value $myVideo.creator.name
		$datum | Add-Member -MemberType NoteProperty -Name VideoCreatorEmail -Value $myVideo.creator.mail
		$datum | Add-Member -MemberType NoteProperty -Name VideoCreationDate -Value $myVideo.created
		$datum | Add-Member -MemberType NoteProperty -Name VideoModificationDate -Value $myVideo.modified
		$datum | Add-Member -MemberType NoteProperty -Name VideoLikes -Value $myVideo.metrics.likes
		$datum | Add-Member -MemberType NoteProperty -Name VideoViews -Value $myVideo.metrics.views
		$datum | Add-Member -MemberType NoteProperty -Name VideoComments -Value $myVideo.metrics.comments
		#the userData value is for the user running the JSON query i.e. did that user view this video. It isn't for information about all users who may have seen this video. There seems to be no information about that other than, total views = metrics.views 
		#$datum | Add-Member -MemberType NoteProperty -Name VideoComments -Value $myVideo.userData.isViewed
		$datum | Add-Member -MemberType NoteProperty -Name Videodescription -Value $myVideo.description
		
		#thanks Johnathan Ogden for these values 
		$datum | Add-Member -MemberType NoteProperty -Name VideoDuration -Value $myVideo.media.duration
		$datum | Add-Member -MemberType NoteProperty -Name VideoHeight -Value $myVideo.media.height
		$datum | Add-Member -MemberType NoteProperty -Name VideoWidth -Value $myVideo.media.width
		$datum | Add-Member -MemberType NoteProperty -Name VideoIsAudioOnly -Value $myVideo.media.isAudioOnly
        $datum | Add-Member -MemberType NoteProperty -Name VideoContentType -Value $myVideo.contentType

        $data += $datum
	
}

$datestring = (get-date).ToString("yyyyMMdd-hhmm")
$csvfileName = ($PowerShellScriptFolder + "\O365StreamVideoDetails_" + $datestring + ".csv")    #<<<< Update this value if you want a different file name 
	
Write-host " -----------------------------------------" -ForegroundColor Green
Write-Host (" >>> writing to file {0}" -f $csvfileName) -ForegroundColor Green
$data | Export-csv $csvfileName -NoTypeInformation
Write-host " ------------------ DONE -----------------------" -ForegroundColor Green