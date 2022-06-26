const path = require("path");
const webpack = require("webpack");

const clientManifest = require('./build/asset-manifest.json'); // reactapp generated assets mappings after client build


module.exports = {
    entry: "./src/edge/index.js",

    target: "node",

    externals: [],

    output: {
        path: path.resolve("edge-build"),
        filename: "index.js",
        library: "index",
        libraryTarget: "umd",
    },
    module: {
        rules: [
            {
                test: /\.(js|jsx|mjs)$/,
                use: "babel-loader",
            },
            {
                test: /\.(svg|jpe?g|gif|png)$/,
                use: [
                    {
                        loader: 'file-loader',
                        options: {
                            publicPath: url => url, // override the default publicPath to return the file utl as it's
                            emitFile: false, // don't emit assets, just use them as it is from the client build
                            name(resourcePath) {
                                const filename = path.basename(resourcePath); // get file name from the path
                                 // load the current file url from client generated paths
                                return clientManifest.files[`static/media/${filename}`];
                            },
                        },
                    },
                ],
            },
            {
                test: /\.(scss|css)$/,
                use: 'ignore-loader', // ignore loader for css and scss because they are handled in the client build
            }
        ],
    },
    plugins: [
        new webpack.ProvidePlugin({
            "React": "react",
        }),
        new webpack.DefinePlugin({
            ASSET_MAIN_JS_FILE_SRC: JSON.stringify(clientManifest.files["main.js"]),
            ASSET_MAIN_CSS_FILE_SRC: JSON.stringify(clientManifest.files["main.css"]),
        })
    ],
};