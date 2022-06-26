import React from "react";
import ReactDOMServer from "react-dom/server";
import App from "../App";
import config from "./config.json";

const indexFile = `
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="theme-color" content="#000000" />
    <meta
      name="description"
      content="Web site created using create-react-app"
    />
    <title>React App SSR</title>
    <script defer="defer" src="${ASSET_MAIN_JS_FILE_SRC}"></script>
    <link href="${ASSET_MAIN_CSS_FILE_SRC}" rel="stylesheet">
  </head>
  <body>
    <noscript>You need to enable JavaScript to run this app.</noscript>
    <div id="root"></div>
    <div>Rendered on Edge</div>
  </body>
</html>
`;

const handler = async function (event, context, callback) {
    try {
        const request = event.Records[0].cf.request;
        // console.log(request);
        const app = ReactDOMServer.renderToString(<App/>);
        const html = indexFile.replace(
            '<div id="root"></div>',
            // `<div id="root">server side rendered</div>`
            `<div id="root">${app}</div>`
        );
        const response = {
            status: "200",
            statusDescription: "OK",
            headers: {
                "cache-control": [
                    {
                        "key": "Cache-Control",
                        "value": "max-age=100"
                    }
                ],
                "content-type": [
                    {
                        "key": "Content-Type",
                        "value": "text/html"
                    }
                ]
            },
            body: html,
        };
        callback(null, response)
    } catch (error) {
        console.log(`Error ${error.message}`);
        return `Error ${error}`;
    }
};

export {handler}