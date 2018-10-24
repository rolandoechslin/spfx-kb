public static class UpdateUserDetails
    {
        // tip - use Managed Service Identity + Key Vault in real-life. In this example, AAD app registration details are kept simple/in code.. 
        public static string resourceId = "https://graph.microsoft.com";
        public static string tenantId = "TODO";
        public static string authString = "https://login.microsoftonline.com/" + tenantId;
        public static string upn = string.Empty;
        public static string clientId = "TODO";
        public static string clientSecret = "TODO";

        // N.B. always use a static HttpClient object, so that one is not instantiated for every function instance/execution..
        private static HttpClient _sharedHttpClient = new HttpClient();

        [FunctionName("UpdateUserDetails")]
        public static async Task<HttpResponseMessage> Run([HttpTrigger(AuthorizationLevel.Function, "post", "options", Route = null)]HttpRequestMessage req, TraceWriter log)
        {
            log.Info("Function 'UpdateUserDetails' started.");

            /* expected to be passed:
             *  { 
             *     userPrincipalName:"cob@chrisobrien.com",
             *     displayName:"Chris O'Brien",
             *     jobTitle:"Updated from function",
             *     officeLocation:"Manchester",
             *     mobilePhone:"555-5656"
             *  }    
             */

            try
            {
                // get request body..
                dynamic data = await req.Content.ReadAsAsync<object>();
                string userName = data.userPrincipalName;
                log.Info(string.Format("Received username '{0}' from caller", userName));

                // obtain auth token using ClientCredentials (app-only)..
                var authenticationContext = new AuthenticationContext(authString, false);

                ClientCredential clientCred = new ClientCredential(clientId, clientSecret);
                AuthenticationResult authenticationResult = await authenticationContext.AcquireTokenAsync(resourceId, clientCred);
                string token = authenticationResult.AccessToken;
                if (!string.IsNullOrEmpty(token))
                {
                    log.Verbose("Successfully obtained access token..");
                }

                // call the Graph to update details for this user..
                string requestUrl = string.Format("https://graph.microsoft.com/v1.0/users/{0}", userName);
                log.Info(string.Format("About to hit Graph endpoint: '{0}'.", requestUrl));

                var userDetails = data;
                var userDetailsJson = JsonConvert.SerializeObject(userDetails);

                HttpRequestMessage requestMsg = new HttpRequestMessage(new HttpMethod("PATCH"), requestUrl);
                requestMsg.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
                requestMsg.Content = new StringContent(userDetailsJson, Encoding.UTF8, "application/json");

                log.Info(string.Format("Sending request: {0}", requestMsg.ToString()));

                HttpResponseMessage response = _sharedHttpClient.SendAsync(requestMsg).Result;
                string responseString = response.Content.ReadAsStringAsync().Result;
                if (response.IsSuccessStatusCode)
                {
                    log.Info(string.Format("Successfully updated user record!"));
                    return req.CreateResponse(HttpStatusCode.OK, new { summary = "Success" });
                }
                else
                {
                    log.Error(string.Format("Failed to update! Reason '{0}'.", response.ReasonPhrase));
                    log.Error(string.Format("Error response: '{0}'.", responseString));
                    return req.CreateResponse(HttpStatusCode.InternalServerError, new { summary = "Error" });
                }
            }
            catch (Exception ex)
            {
                log.Error(string.Format("Exception! '{0}'.", ex));
                return req.CreateResponse(HttpStatusCode.InternalServerError, new { summary = "Error" });
            }
        }
    }