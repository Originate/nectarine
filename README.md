# Nectarine [![CircleCI](https://circleci.com/gh/Originate/nectarine/tree/master.svg?style=svg)](https://circleci.com/gh/Originate/nectarine/tree/master)

A way to manage state in JavaScript applications.

* Define a schema to document and enforce the structure of your state
* Built in support for asynchronous loading of data with promises
* Define actions on slices of your state to group updates

## Usage

#### Create a slice (a portion of the store)
```javascript
// store/slices/session.js
import {createSlice} from 'nectarine'

module.exports = createSlice({
  schema: _ => (
    {
      currentUser: {
        name: _,
        email: _
      }
    }
  ),

  actions: {
    initialize: () => {
      // ...
    }
  }
})
```

#### Create a store by combining slices
```javascript
// store/index.js
import {createStore} from 'nectarine'
import sessionSlice from './slices/session'

module.exports = createStore({
  session: sessionSlice
})
```

#### Inject the store into your react application
```javascript
// index.js
import {Provider} from 'nectarine'
import App from './components/app'
import ReactDOM from 'react-dom'
import store from './store'

ReactDOM.render(
  <Provider store={store}>
    <App />
  </Provider>,
  document.getElementById('app')
)
```


#### Connect components
```javascript
// components/navigation.js
import {connect} from 'nectarine'
import React from 'react'

class Navigation extends React.Component {
  // ...
}

module.exports = connect({
  component: Navigation,
  mapProps: (store) => {
    //...
  }
})
```

## Documentation

* API
  * [Top Level Methods](/docs/api/top_level_methods.md)
  * Store Methods
    * [Tree / Leaf](/docs/api/tree_leaf_methods.md)
    * [Map Methods](/docs/api/map_methods.md)
* [Creating a slice](/docs/creating_a_slice.md)
* [Redux Comparison](/docs/redux_comparison.md)
