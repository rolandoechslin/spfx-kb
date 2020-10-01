
// Source: https://mgwdevcom.wordpress.com/2020/09/29/use-graph-api-to-query-sharepoint-list-in-spfx/

export class GraphRepository {
    protected hostUrl: string;
    constructor(protected client: MSGraphClient,
        protected siteAbsoluteUrl,
        protected siteRelativeUrl,
        protected listId: string) {
        this.hostUrl = siteAbsoluteUrl.replace("https://", "").replace(siteRelativeUrl, "");
    }
    public async getListItems<T>(filterQuery: string = ""): Promise<T[]> {
        let graphUrl: string = `/sites/${this.hostUrl}:${this.siteRelativeUrl}:/lists/${this.listId}/items?$expand=fields`;
        if(filterQuery){
            graphUrl += "&$filter=" + filterQuery;
        }
        let request = this.client.api(graphUrl);
        request.header("Prefer", "HonorNonIndexedQueriesWarningMayFailRandomly");
        let response = await request.get();
 
        return response.value;
    }
}

export class GraphRepositoryFactory {
    protected graphClient: MSGraphClient;
    constructor(protected context: WebPartContext) {
 
    }
    public async getRepository(listId: string): Promise<GraphRepository> {
        if (!this.graphClient) {
            this.graphClient = await this.context.msGraphClientFactory.getClient();
        }
        return new GraphRepository(this.graphClient,
            this.context.pageContext.site.absoluteUrl,
            this.context.pageContext.site.serverRelativeUrl,
            listId);
    }
}

// use it
let factory = new GraphRepositoryFactory(this.context);
let repository = await factory.getRepository("<your-list-id");
let items = await repository.getListItems("startswith(fields/Title,'test')");
