### Advantages of Subsites

1.  A subsite can be provisioned by anyone with at least Full Control
    permission (more specifically, the *Create Subsites* permission
    level) on the parent site. I.e. You don’t require a farm or tenant
    admin to provision one for you. (Although in SharePoint Online,
    anyone in a specified AD group can provision an Office 365 Group
    site collection; to provision a standard SharePoint site collection
    on SharePoint Server requires membership in the Farm Administrators
    SharePoint group on the machine running the Central Administration
    website. To provision a Classic SharePoint site collection in Office
    365 requires you to be a Global Admin or SharePoint Online
    administrator)
2.  A subsite can automatically be added to the navigation of the parent
    site if you have the navigation settings configured that way.
3.  A subsite can automatically inherit settings from its parent site
    including permissions, features, and navigation (Ironically this can
    also be a disadvantage as well as I describe in the section below).
    You can optionally adjust some of the settings at the subsite level.
    (for example, decide *not* to inherit navigation settings)
4.  This is quick and easy to setup which is attractive for small
    organizations who don’t have a lot of resources to spend maintaining
    site collections. (although in SharePoint Online, the provisioning
    process for an Office 365 Group site collection is very quick and
    easy, it is not that easy in SharePoint on-premises)
5.  \[Update January 18, 2018\] A subsite automatically inherits content
    types and site columns from its parent site. This is more
    straight-forward to setup than a Content Type Hub which is what is
    required to do the same across site collections.
6.  \[Update January 18, 2018\] Managed Term sets can easily be shared
    across all subsites within a Site Collection if the term set is
    created at the site collection level. Term sets cannot be shared
    across site collections unless it is created at the farm/tenant
    level.

-----

### Disadvantages of Site Collections

1.  It is a boundary for navigation which means navigation is not shared
    across site collections. To visually tie together your site
    collections in a “virtual hierarchy” (i.e. navigation), you will
    need to handle this separately. (Code, manually configured, etc.)
    *\*\*See my comment about the new SharePoint Hub site below to
    address this disadvantage however which will turn this into an
    advantage where you can ‘plug and play’ your site collections into
    whatever kind of navigation is required.*
2.  Content types and site columns can be defined at a site collection
    level but cannot be easily shared across site collections. The
    Content Type hub is a feature built with the intent of this, but in
    my experience it has some usability issues, particularly in
    SharePoint Online.
3.  If you are a small company, you may find it difficult to manage
    multiple site collections if you have advanced branding, navigation,
    feature requirements.

-----

### My thoughts

Let’s get back to the quote from Ignite… why are subsites the spawn of
the devil?

Generally speaking, it’s hard to argue with the fact that site
collections are more flexible. Each site collection can be viewed as a
granular ‘unit of work’. They allow you to control permissions,
features, storage, branding and target data protection and retention
controls at a more targeted level. A flat architecture like this allows
you to ‘plug and play’ site collections into whatever kind of
navigational hierarchy is required – the announcement of the SharePoint
Hub site at Microsoft Ignite is a feature being built to allow you to
build this navigation thru the User Interface. You will be able to
associate a site collection with a SharePoint Hub by the click of a
button and easily move it from one Hub to another if required. This is
great news.

-----
Source: https://joannecklein.com/2017/11/03/sharepoint-site-collection-advantages/