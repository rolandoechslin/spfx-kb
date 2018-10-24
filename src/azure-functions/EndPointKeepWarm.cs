using System;
using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;

namespace COB.AzureFunctions
{
    public static class EndPointKeepWarm
    {
        private static HttpClient _httpClient = new HttpClient();
        private static string _endPointsToHit = Environment.GetEnvironmentVariable("EndPointUrls");

        [FunctionName("EndPointKeepWarm")]
        // run every 15 minutes..
        public static async Task Run([TimerTrigger("0 */10 * * * *")]TimerInfo myTimer, TraceWriter log)
        {
            log.Info($"Run(): EndPointKeepWarm function executed at: {DateTime.Now}. Past due? {myTimer.IsPastDue}");

            if (!string.IsNullOrEmpty(_endPointsToHit))
            {
                string[] endPoints = _endPointsToHit.Split(';');
                foreach(string endPoint in endPoints)
                {
                    string tidiedUrl = endPoint.Trim();
                    if (!tidiedUrl.EndsWith("/"))
                    {
                        tidiedUrl += "/";
                    }
                    log.Info($"Run(): About to hit URL: '{tidiedUrl}'");

                    HttpResponseMessage response = await hitUrl(tidiedUrl, log);
                }
            }
            else
            {
                log.Error($"Run(): No URLs specified in environment variable 'EndPointUrls'. Expected a single URL or multiple URLs " +
                    "separated with a semi-colon (;). Please add this config to use the tool.");
            }

            log.Info($"Run(): Completed..");
        }

        private static async Task<HttpResponseMessage> hitUrl (string url, TraceWriter log)
        {
            HttpResponseMessage response = await _httpClient.GetAsync(url);
            if (response.IsSuccessStatusCode)
            {
                log.Info($"hitUrl(): Successfully hit URL: '{url}'");
            }
            else
            {
                log.Error($"hitUrl(): Failed to hit URL: '{url}'. Response: {(int)response.StatusCode + " : " + response.ReasonPhrase}");
            }

            return response;
        }
    }
}