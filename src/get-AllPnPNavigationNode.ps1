$TopNavs = Get-PnPNavigationNode -Location TopNavigationBar | Select Title,Url, Id


foreach($TopNav in $TopNavs)
{
    $node = Get-PnPNavigationNode -Id $TopNav.Id 

    Write-Host
    Write-Host "TopNav_Id: [" $TopNav.Id "]" "Title: " $TopNav.Title "Url: " $TopNav.Url
    Write-Host

    if($node.Children)
    {
        $child = $node.Children | Select Title, Url, Id     #gets topnavs children

        foreach($child in $node.Children){

        Write-Host "   ++ child_Id: [[ " $child.Id"]]" "Title: " $child.Title "Url: " $child.Url
        Write-Host

        #get 3rd level terms
        $subChildNode = Get-PnPNavigationNode -Id $child.Id 

        if($subChildNode.Children)
        {
          $subChild = $subChildNode.Children | Select Title, Url, Id   #gets childrens children

          foreach($subChild in $subChildNode.Children)
          {
            Write-Host "     ++ subChild_Id: " $subChild.Id "Title: " $subChild.Title "Url: " $subChild.Url
          }
        }
        }
    }
}