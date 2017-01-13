# Nectarine

A way to manage state in JavaScript applications.

* Define a schema to document and enforce the structure of your state
* Built in support for asynchronous loading of data via promises
* Define actions on slices of your state to group updates

## Usage

#### Define a slice (a portion of state)
```
# store/session.ls
require! {
  'nectarine': {create-slice}
}

module.exports = create-slice do
  schema: (_) ->
    current-user:
      name: _
      email: _

```

#### Combine slices
```
# store/index.ls
require! {
  'nectarine': {combine-slices}
}

module.exports = combine-slices do
  session: require('./session')
```

#### Inject the slice into your react application
```
# index.coffee
require! {
  './components/app': App
  './store': Store
  'nectarine': {Provider}
}

AppProvider = Provider(App, store)
component = React.createElement AppProvider, {}

ReactDOM.render component, document.getElementById('app')
```


#### Connect components
```
# components/navigation.ls
require! {
  'nectarine': {connect}
  'react': React
}

class Navigation extends React.Component
  # ...

module.exports = connect do
  component: Navigation
  map-props: (store) ->
    # ...
```
