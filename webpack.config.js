var webpack = require('webpack');

module.exports = {
    entry: `${process.env.FunctionRelative}/src`,
    output: {
        path: `${process.env.FunctionRelative}`,
        filename: 'index.js',
        library: 'default',
        libraryTarget: 'commonjs2'
    },
    target: 'node',

    resolve: {
        extensions: ['.ts', '.js']
    },

    module: {
        rules: [{
            test: /\.ts$/,
            use: [{ loader: 'ts-loader' }]
        }]
    },

    plugins: [
        new webpack.optimize.UglifyJsPlugin({
            compress: { warnings: false }
        })
    ]
};