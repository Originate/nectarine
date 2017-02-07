# Nectarine [![CircleCI](https://circleci.com/gh/Originate/nectarine/tree/master.svg?style=svg)](https://circleci.com/gh/Originate/nectarine/tree/master)

A way to manage state in JavaScript applications.

* Define a schema to document and enforce the structure of your state
* Built in support for asynchronous loading of data with promises
* Define actions on slices of your state to group updates

## Usage

#### Create a slice
```javascript
// slices/session.js
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

#### Combine slices
```javascript
// slices/root.js
import {combineSlices} from 'nectarine'
import sessionSlice from './session'

module.exports = combineSlices({
  session: sessionSlice
})
```

#### Inject the root slice into your react application
```javascript
// index.js
import App from './components/app'
import rootSlice from './slices/root'
import {Provider} from 'nectarine'

AppProvider = Provider({component: App, slice: rootSlice})

ReactDOM.render(<AppProvider/>, document.getElementById('app'))
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
  mapProps: (rootSlice) => {
    //...
  }
})
```
