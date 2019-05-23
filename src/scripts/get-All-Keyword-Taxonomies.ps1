{
    #Object array.
    $TermsCollection = @();
 
    #Get all term groups.
    $TermGroups = Get-PnPTermGroup;
 
    #Foreach term group.
    Foreach($TermGroup in $TermGroups)
    {
        #Get all term sets.
        $TermSets = $TermGroup | Get-PnPTermSet;
 
        #Foreach term set.
        Foreach($TermSet in $TermSets)
        {
            #Get all terms.
            $Terms = Get-PnPTerm -TermGroup $TermGroup.Name -TermSet $TermSet.Name;
 
            #Foreach term.
            Foreach($Term in $Terms)
            {
                #If a term is present.
                If($Term)
                {
                    #Create a new object.
                    $TermCollection = New-Object -TypeName PSObject;
 
                    #Add value to the object.
                    Add-Member -InputObject $TermCollection -Membertype NoteProperty -Name "TermGroupName" -Value ($TermGroup.Name);
                    Add-Member -InputObject $TermCollection -Membertype NoteProperty -Name "TermGroupId" -Value ($TermGroup.Id);
                    Add-Member -InputObject $TermCollection -Membertype NoteProperty -Name "TermGroupSetName" -Value ($TermSet.Name);
                    Add-Member -InputObject $TermCollection -Membertype NoteProperty -Name "TermGroupSetId" -Value ($TermSet.Id);
                    Add-Member -InputObject $TermCollection -Membertype NoteProperty -Name "TermName" -Value ($Term.Name);
                    Add-Member -InputObject $TermCollection -Membertype NoteProperty -Name "TermId" -Value ($Term.Id);
 
                    #Add to the object array.
                    $TermsCollection += $TermCollection;
                }
            }
        }
    }
 
    #Return terms.
    Return $TermsCollection;
}
 
#Get all keywords.
$Keywords = Get-SPTaxKeyword;