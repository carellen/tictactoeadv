import { Controller } from 'stimulus'
import StimulusReflex from 'stimulus_reflex'

export default class extends Controller {
  static targets = [ 'error' ]

  connect() {
    StimulusReflex.register(this)
  }

  success() {
    const [data, status, xhr] = event.detail

    this.stimulate("Login#success", data)
    console.log('Success!')
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
}
