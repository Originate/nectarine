# Nectarine

A way to manage state in JavaScript applications.

* Define a schema to document and enforce the structure of your state
* Built in support for asynchronous loading of data with promises
* Define actions on slices of your state to group updates

## Usage

#### Define a slice (a portion of state)
```livescript
# slice/session.ls
require! {
  'nectarine': {create-slice}
}

module.exports = create-slice do
  schema: (_) ->
    current-user:
      name: _
      email: _

  actions:
    initialize: ->
      # ...
```

#### Combine slices
```livescript
# slice/index.ls
require! {
  'nectarine': {combine-slices}
}

module.exports = combine-slices do
  session: require('./session')
```

#### Inject a slice into your react application
```livescript
# index.coffee
require! {
  './components/app': App
  './slice'
  'nectarine': {Provider}
}

AppProvider = Provider {component: App, slice}
component = React.createElement AppProvider, {}

ReactDOM.render component, document.getElementById('app')
```


#### Connect components
```livescript
# components/navigation.ls
require! {
  'nectarine': {connect}
  'react': React
}

class Navigation extends React.Component
  # ...

module.exports = connect do
  component: Navigation
  map-props: (root-slice) ->
    # ...
```
