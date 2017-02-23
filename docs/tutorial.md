# Tutorial

## Creating and using a store

```js
// store/user_session_slice.js
import {createSlice} from 'nectarine'

const userSessionSlice = createSlice({
  schema: (_) => {
    id: _,
    profile: {
      email: _(type: 'string'),
      name: _(type: 'string')
    }
  }
})

export default userSessionSlice
```

```js
// store/index.js
import {createStore} from 'nectarine'
import userSession from './user_session_slice'

const store = createStore({userSession})

export default store
```

The store object looks very similar to the schema.
However, all data is encapsulated and can only be retrieved and updated with special methods.
All special `nectarine` methods begin with a `$`

```js
store.userSession.id.$set('user1')
store.userSession.profile.email.$set('john.doe@example.com')
store.userSession.profile.name.$set('John Doe')

store.$get() // => {userSession: {id: 'user1', profile: {email: 'john.doe@example.com', name: 'John Doe'}}}
store.userSession.$get() // => {id: 'user1', profile: {email: 'john.doe@example.com', name: 'John Doe'}}
store.userSession.profile.$get() // => {email: 'john.doe@example.com', name: 'John Doe'}
store.userSession.profile.email.$get() // => 'john.doe@example.com'
```

You can set an object all at once, which is equivalent to calling `$set` on each child.

```js
store.userSession.$set({
  id: 'user1',
  profile: {
    email: 'john.doe@example.com',
    name: 'John Doe'
  }
})
// is equivalent to
store.userSession.id.$set('user1')
store.userSession.profile.$set({
  email: 'john.doe@example.com',
  name: 'John Doe'
})
// is equivalent to
store.userSession.id.$set('user1')
store.userSession.profile.email.$set('john.doe@example.com')
store.userSession.profile.name.$set('John Doe')
```

Each location in the store has three states: data, loading, and error (mirroring a promise).
Data can also be set with promises.

```js
store.userSession.$fromPromise(api.login({username: 'johnDoe123', password: 'secret'}))

// Promise is pending
store.userSession.$get() // => throws because the data is loading
store.userSession.$isLoading() // => true
store.userSession.$getError() // => null

// Promise resolves with {id: 'user1', profile: {email: 'john.doe@example.com', name: 'John Doe'}}
store.userSession.$get() // => {id: 'user1', profile: {email: 'john.doe@example.com', name: 'John Doe'}}
store.userSession.$isLoading() // => false
store.userSession.$getError() // => null

// Promise rejects with Error('Invalid Credentials')
store.userSession.$get() // => throws because the data errored
store.userSession.$isLoading() // => false
store.userSession.$getError() // => Error('Invalid Credentials')
```

You can use `$getOrElse()` to get the data if its available and otherwise return null.
You can also pass in the default value. See [here](./api/tree_leaf_methods.md#getorelsedefaultvalue)

## Usage with React

```js
// index.js
import React from 'react'
import {render} from 'react-dom'
import {Provider} from 'nectarine'
import store from './store'
import App from './components/App'

render(
  <Provider store={store}>
    <App />
  </Provider>,
  document.getElementById('root')
)
```

```js
// containers/user_navigation.js
import {connect} from 'nectarine'
import UserNavigation from '../components/user_navigation'

const mapProps = (store) => {
  return {
    profile: store.userSession.profile.$get()
  }
}

export default connect({
  component: UserNavigation,
  mapProps
})
```

## Object with dynamic keys and values that follow a schema

This can be achieved with the the second argument to schema. We call it `map`.

```js
// store/user_session_slice.js
import {createSlice} from 'nectarine'

const userSessionSlice = createSlice({
  schema: (_, map) => {
    id: _,
    profile: {
      email: _,
      name: _
    },
    projects: map({
      summary: _,
      title: _
    })
  }
})

export default userSessionSlice
```

```js
// Values can be accessed with $key(). New elements are created on the fly.
store.userSession.projects.$key('project1').$get() // => {summary: null, title: null}
store.userSession.projects.$key('project1').$set({
  summary: 'A way to manage state in JavaScript applications.',
  title: 'Nectarine'
})

// Returns all accessed keys
store.userSession.projects.$keys() // ['project1']

// Returns a mapping for all accessed keys with data
store.userSession.projects.$getAll() // {'project1': {summary: <...>, title: 'Nectarine'}}
```

## Actions

You can add your own methods to slices by also supplying an `actions` object.
The slice will be exposed to actions with `this.slice`.
The store will also be exposed with `this.store` if other actions need to be accessed.
See [here](./creating_a_slice.md#actions) for more information.

```js
// store/user_session_slice.js
import {createSlice} from 'nectarine'

let nextProjectId = 0

const userSessionSlice = createSlice({
  schema: (_, map) => {
    id: _,
    profile: {
      email: _,
      name: _
    },
    projects: map({
      summary: _,
      title: _
    })
  },
  actions: {
    addProject: function ({summary, title}) {
      const projectId = nextProjectId++
      this.slice.projects.$key(projectId).$set({summary, title})
    }
  }
})

export default userSessionSlice
```

The actions are added as methods on the slice.

```js
store.userSession.addProject({
  summary: 'A way to manage state in JavaScript applications.',
  title: 'Nectarine'
})
```
