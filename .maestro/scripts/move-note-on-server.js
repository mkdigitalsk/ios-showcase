// Edits a note from outside the app, so the app's next save carries a stale If-Match.
// Reads TITLE, EMAIL and PASSWORD; writes output.movedStatus.
// TODO(template): the API host this template's server answers on.
const base = 'https://api.showcase.mkdigital.sk/v1'

const signedIn = http.post(base + '/auth/sign-in', {
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ email: EMAIL, password: PASSWORD }),
})
const authorization = 'Bearer ' + json(signedIn.body).token

const notes = json(http.get(base + '/notes', { headers: { Authorization: authorization } }).body)
const note = notes.filter(function (candidate) { return candidate.title === TITLE })[0]

const moved = http.put(base + '/notes/' + note.id, {
  headers: { Authorization: authorization, 'Content-Type': 'application/json', 'If-Match': note.etag },
  body: JSON.stringify({ title: TITLE, content: 'changed on the server' }),
})
output.movedStatus = moved.status
