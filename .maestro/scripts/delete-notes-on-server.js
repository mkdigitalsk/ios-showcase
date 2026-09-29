// Deletes every note titled TITLE, so a flow that failed halfway leaves nothing on the shared account.
// Reads TITLE, EMAIL and PASSWORD.
// TODO(template): the API host this template's server answers on.
const base = 'https://api.showcase.mkdigital.sk/v1'

const signedIn = http.post(base + '/auth/sign-in', {
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ email: EMAIL, password: PASSWORD }),
})
const authorization = 'Bearer ' + json(signedIn.body).token

const notes = json(http.get(base + '/notes', { headers: { Authorization: authorization } }).body)
notes
  .filter(function (note) { return note.title === TITLE })
  .forEach(function (note) { http.delete(base + '/notes/' + note.id, { headers: { Authorization: authorization } }) })
