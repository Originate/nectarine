require! {
  'webpack-node-externals'
}


module.exports =

  entry: './src'


  output:
    filename: 'index.js'
    library-target: 'commonjs2'
    path: __dirname
    pathinfo: yes


  resolve: extensions: <[.ls]>


  target: 'node'


  externals: [webpack-node-externals!,  'react']


  module:
    rules: [
      * test: /\.ls$/
        use: \livescript-loader
    ]
