import {handler} from "./index"

const event = {
    "Records": [
        {
            "cf": {
                "config": {
                    "distributionId": "EXAMPLE"
                },
                "request": {
                    "headers": {
                        "host": [
                            {
                                "key": "Host",
                                "value": "d123.cf.net"
                            }
                        ],
                        "user-name": [
                            {
                                "key": "User-Name",
                                "value": "CloudFront"
                            }
                        ]
                    },
                    "clientIp": "2001:cdba::3257:9652",
                    "uri": "/edgessr",
                    "method": "GET"
                },
                "response": {
                    "status": "200",
                    "statusDescription": "OK",
                    "headers": {
                        "x-cache": [
                            {
                                "key": "X-Cache",
                                "value": "Hello from Cloudfront"
                            }
                        ]
                    }
                }
            }
        }
    ]
}

describe("test ssr handler function", () => {

    test("Renders app correctly", () => {
        const callback = (_, response) => {
            expect(response).toEqual({
                "headers": {
                    "cache-control": [{
                        "key": "Cache-Control",
                        "value": "max-age=100",
                    },
                    ],
                    "content-type": [
                        {
                            "key": "Content-Type",
                            "value": "text/html",
                        },
                    ],
                },
                "status": "200",
                "statusDescription": "OK",

                "body": `
             <!DOCTYPE html>
             <html lang=\"en\">
               <head>
                 <meta charset=\"utf-8\" />
                 <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\" />
                 <meta name=\"theme-color\" content=\"#000000\" />
                 <meta
                   name=\"description\"
                   content=\"Web site created using create-react-app\"
                 />
                 <title>React App SSR</title>
               </head>
               <body>
                 <noscript>You need to enable JavaScript to run this app.</noscript>
                 <div id=\"root\"><div class=\"App\"><header class=\"App-header\"><img src=\"logo.svg\" class=\"App-logo\" alt=\"logo\"/><p>Edit <code>src/App.js</code> and save to reload.</p><a class=\"App-link\" href=\"https://reactjs.org\" target=\"_blank\" rel=\"noopener noreferrer\">Learn React</a></header></div></div>
                 <div>Rendered on Edge</div>
               </body>
             </html>
             `,
            })
        }
        handler(event, {}, callback)
    })
})