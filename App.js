import React, { Component } from "react";
import { StyleSheet, Dimensions } from "react-native";
import loginPage from "./source/login/loginPage"; //import the js files you create here.
import { StackNavigator } from "react-navigation";
import DamageCamera from "./damage-camera";

class CameraScreen extends Component {
  static navigationOptions = {
    title: "Camera"
  };
  render() {
    //const { navigate } = this.props.navigation;
    // can use the navigate as a onpress to start
    // navigating to directed page. See loginPage.js.
    return <DamageCamera style={styles.preview} />;
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
  homeFormat: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    height: Dimensions.get("window").height,
    width: Dimensions.get("window").width
  }
});
