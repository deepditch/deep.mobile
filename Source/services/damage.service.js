import axios from "axios";
import AuthService from "./auth.service";
import LocationService from "./location.service";

export default class DamageService {
  async reportDamage(uri) {
    const data = new FormData();

    data.append("image", {
      uri: uri,
      type: "image/jpg",
      name: `${new Date().getTime()}.jpg`
    });

    return Promise.all([
      new LocationService().getCurrentLocation(),
      new AuthService().getToken()
    ])
      .then(values => {
        data.append("latitude", values[0].coords.latitude);
        data.append("longitude", values[0].coords.longitude);

        const config = {
          method: "POST",
          headers: {
            Accept: "application/json",
            "Content-Type": "multipart/form-data;",
            authorization: "Bearer " + values[1]
          },
          body: data
        };

        return fetch("http://216.126.231.155/api/road-damage/new", config)
          .then(responseData => {
            console.log(responseData);
          })
          .catch(err => {
            console.log(err);
          });
      })
      .catch(err => {
        console.log(err);
        throw error;
      });
  }
}
