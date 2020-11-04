import { Controller } from 'stimulus'
import StimulusReflex from 'stimulus_reflex'
import consumer from '../channels/consumer'
import CableReady from 'cable_ready'

export default class extends Controller {
  static targets = [ 'current' ]

  connect() {
    StimulusReflex.register(this)
  }

  create() {
    event.preventDefault()
    event.stopPropagation()
    this.stimulate('Game#create', event.target).then(_ => {
      const gameId = this.currentTarget.dataset.id
      this.subscribe(gameId)
    })
  }

  join() {
    const gameId = event.currentTarget.dataset['id']
    this.subscribe(gameId)
    this.stimulate('Game#join', event.currentTarget)
  }

  subscribe(gameId) {
    consumer.subscriptions.create({channel: 'GameChannel', game: gameId}, {
      connected () {
        this.send({ message: `Connected to ${gameId} game` })
      },

      received (data) {
        if (data.cableReady) CableReady.perform(data.operations)
      }
    })
  }
}
