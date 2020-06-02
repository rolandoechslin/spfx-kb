# Source: https://capacreative.co.uk/2020/05/31/testing-user-preferred-language-of-sharepoint-site-with-pnp-powershell/

Connect-PnPOnline https://<tenant>.sharepoint.com/sites/<site>
Get-PnPListItem -List "User Information List" -Id 7 # Me

# -OR- #

$userEmail = "paul.bullock@mytenant.co.uk"
$CamlQuery = @"
<View>
    <Query>
        <Where>
            <Eq>
                <FieldRef Name='EMail' />
                <Value Type='Text'>$userEmail</Value>
            </Eq>
        </Where>
    </Query>
</View>
"@

$item = Get-PnPListItem -List "User Information List" -Query $CamlQuery

# Language Reference: https://capacreative.co.uk/resources/reference-sharepoint-online-languages-ids/
$item["MUILanguages"] = "de-de"
$item.Update()
Invoke-PnPQuery