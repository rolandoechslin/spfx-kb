// Source: https://gist.github.com/BasantPandey/05189832546f2c6cc0bd008fcfec3264

var Email= function(){
    // Email Either email groupname or email address
        var from = 'abc.yahoo.com',
            to = 'abc.yahoo.com',
            cc = 'abc.yahoo.com',  
            subject='My Email Subject'; 
            
        this.options = this.options || {};
        this.options['fromEmail'] = this.options['fromEmail'] || {};
        this.options['toEmail'] = this.options['toEmail'] || {};
        this.options['ccEmail'] = this.options['ccEmail'] || {};
        this.options['subject'] = this.options['subject'] || {};
        this.options['fromEmail'] = from;
        this.options['toEmail'] = to;
        this.options['ccEmail'] = cc;
        this.options['subject'] = subject;
        
        
    }
    function sendEmail(emailObj,body) {
            var that =emailObj;
            //Get the relative url of the site
            var ServiceUrl = ((_spPageContextInfo.webServerRelativeUrl==='/')?'/':_spPageContextInfo.webServerRelativeUrl);
            
            var siteurl = ServiceUrl;
            
            var urlTemplate = siteurl + "/_api/SP.Utilities.Utility.SendEmail";
    
            $.ajax({
                contentType: 'application/json',
                url: urlTemplate,
                type: "POST",
                data: JSON.stringify({
                    'properties': {
                        '__metadata': {
                            'type': 'SP.Utilities.EmailProperties'
                        },
                        'From': that.options.fromEmail,
                        'To': {
                            'results': [that.options.toEmail]
                        },
                        'CC': {
                            'results': [that.options.ccEmail]
                        },
                        'Body': body,
                        'Subject': that.options.subject
                    }
                }),
                headers: {
                    "Accept": "application/json;odata=verbose",
                    "content-type": "application/json;odata=verbose",
                    "X-RequestDigest": jQuery("#__REQUESTDIGEST").val()
                },
                success: function (data) {
    
                },
                error: function (err) {
                     // alert('Error in sending Email: ' + JSON.stringify(err));
                      alert('Error in sending Email', 1);
                }
            });
        }
        
    var sendEmailObj = new Email();
    var emailbody = 'hi this is email body';
    sendEmail(sendEmailObj,emailbody);