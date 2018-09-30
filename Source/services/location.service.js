export default class LocationService {
  async getCurrentLocation() {
    return new Promise(function(resolve, reject) {
      navigator.geolocation.getCurrentPosition(
        position => {
          resolve(position);
        },
        err => {
          reject(err);
        },
        { timeout: 10000 }
      );
    });
  }
}
