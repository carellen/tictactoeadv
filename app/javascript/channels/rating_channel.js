import consumer from './consumer'
import CableReady from 'cable_ready'

consumer.subscriptions.create('RatingChannel', {
  connected () {
    this.send({ message: 'Rating is live' })
  },

  received (data) {
    if (data.cableReady) CableReady.perform(data.operations)
  }
});
