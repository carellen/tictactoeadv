import { Controller } from 'stimulus'
import StimulusReflex from 'stimulus_reflex'
import consumer from '../channels/consumer'

export default class extends Controller {
  static targets = [ 'error' ]

  connect() {
    StimulusReflex.register(this)
  }

  success() {
    const [data, status, xhr] = event.detail

    this.stimulate("Login#success", data).then(_ => {
      console.log('Login#success!')
      consumer.connection.close()
    })
  }

  failure() {
    const [data, status, xhr] = event.detail
    try {
      const error = JSON.parse(xhr.responseText)
      setTimeout(() => this.stimulate("Login#failure", { error: null }), 2000)
      this.stimulate("Login#failure", error)
    } catch (e) {
      console.log(e)
    }
  }

  logout() {
    this.stimulate("Login#logout").then(_ => {
      console.log('Logout#success!')
      consumer.connection.close()
    })
  }
}
