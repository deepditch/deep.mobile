import React, { Component } from "react";
import { StyleSheet, Dimensions, Text } from "react-native";
import loginPage from "./source/login/loginPage"; //import the js files you create here.
import { StackNavigator } from "react-navigation";
import Camera from "react-native-camera";
import DamageService from "./source/services/damage.service";

class CameraScreen extends Component {
  static navigationOptions = {
    title: "Camera"
  };

  componentDidMount() {
    navigator.geolocation.requestAuthorization();
  }

  render() {
    //const { navigate } = this.props.navigation;
    // can use the navigate as a onpress to start
    // navigating to directed page. See loginPage.js.
    return (
      <Camera
        ref={cam => {
          this.camera = cam;
        }}
        style={styles.preview}
        aspect={Camera.constants.Aspect.fill}
        captureTarget={Camera.constants.CaptureTarget.disk}
      >
        <Text style={styles.capture} onPress={this.takePicture.bind(this)}>
          {" "}
          [CAPTURE]{" "}
        </Text>
      </Camera>
    );
  }

  async takePicture() {
    this.camera
      .capture()
      .then(data => {
        if (data.path) {
          new DamageService()
            .reportDamage(data.path)
            .then(response => {})
            .catch(err => {});
        }
      })
      .catch(err => console.error(err));
  }
}

//=============//
//Basically using stacknavigatior to create
//the pages to navigate to one page to another.
//=============//

const NavApp = StackNavigator({
  Home: { screen: loginPage }, //calls the loginPage from loginPage.js.
  Camera: { screen: CameraScreen } // calls the camera screen from above, should be moved to its own .js later.
});

export default class App extends Component {
  render() {
    return <NavApp />;
  }
}

const styles = StyleSheet.create({
  preview: {
    flex: 1,
    justifyContent: "flex-end",
    alignItems: "center",
    height: Dimensions.get("window").height,
    width: Dimensions.get("window").width
  },
  capture: {
    flex: 0,
    backgroundColor: "#ffffff",
    borderRadius: 5,
    color: "#000",
    padding: 10,
    margin: 40
  },
  homeFormat: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    height: Dimensions.get("window").height,
    width: Dimensions.get("window").width
  }
});
