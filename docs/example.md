# Example

```js
// store/user_session_slice.js
import {createSlice} from 'nectarine'

const userSessionSlice = createSlice({
  schema: (_) => {
    id: _,
    profile: {
      email: _,
      name: _
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

# Using a store

The store object looks very similar to the schema.
At any point you can use `$get()` to retrieve the stored data

```js
store.$get() // => {userSession: {id: null, profile: {email: null, name: null}}}
store.userSession.$get() // => {id: null, profile: {email: null, name: null}}
store.userSession.profile.$get() // => {email: null, name: null}
```

You can set an object all at once or set the leaves as you would like

```js
store.userSession.$set({id: 'user1', profile: {email: 'john.doe@example.com', name: 'John Doe'}})
// is equivalent to
store.userSession.id.$set('user1')
store.userSession.profile.$set({email: 'john.doe@example.com', name: 'John Doe'})
// is equivalent to
store.userSession.id.$set('user1')
store.userSession.profile.email.$set('john.doe@example.com')
store.userSession.profile.name.$set('John Doe')
```

Each location in the store has three states: data, loading, and error (mirroring a promise).

```js
store.userSession.$fromPromise(api.login({username: 'johnd', password: '123456'}))

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
