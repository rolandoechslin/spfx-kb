# Welcome
Check-SPOBrokenLink detects and lists all broken links within SharePoint Online sites.

As is, this is my tool to check broken links in SharePoint Online. The tool need many improvments. Feel free to use it, if you improve it, please share with me.

https://blog.p-difm.com/sharepoint-online-check-for-broken-links/

# How to use it ?
1. Download all the files a put them all in a same directory
2. Set variables according to your environment
3. Set a test filter in $TenantSites
4. Set a test filter in $TenantSitePages

# Next improvements could be...
1. Find a better regex pattern to identify URL
2. Consider using ConvertFrom-Json to obtain an object of the page's content
3. Currently only pages are checked, we need to look in lists too
4. Improve code in general
