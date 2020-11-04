import consumer from './consumer'
import CableReady from 'cable_ready'

consumer.subscriptions.create('GameListChannel', {
  connected () {
    this.send({ message: 'GameList is live' })
  },

  received (data) {
    if (data.cableReady) CableReady.perform(data.operations)
  }
});
