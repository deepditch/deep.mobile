import AuthService from "./auth.service";
import config from "../../project.config";

export default class DamageService {
  async parseJSON(response) {
    return new Promise(resolve =>
      response.json().then(json =>
        resolve({
          status: response.status,
          ok: response.ok,
          json
        })
      )
    );
  }

  async getDamages() {
    var token = await new AuthService().getToken();
    const requestBody = {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
        authorization: "Bearer " + token
      }
    };

    return new Promise((resolve, reject) => {
      fetch(config.API_BASE_PATH + "/road-damage", requestBody)
        .then(this.parseJSON)
        .then(response => {
          if (!response.ok) return reject(response.json);
          return resolve(response.json.data);
        });
    });
  }
}
