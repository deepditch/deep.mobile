import React, { Component } from "react";

import loginPage from "./source/login/loginPage"; //import the js files you create here.
import registrationPage from "./source/login/registrationPage"; //import the js files you create here.
import DamageCameraScreen from "./source/damage-camera-screen";

import { StackNavigator, DrawerNavigator } from "react-navigation";

import { PermissionsAndroid } from "react-native";

const cameraScreen = StackNavigator({
  Camera: { screen: DamageCameraScreen }
});

const DrawerStack = DrawerNavigator({
  Camera: { screen: cameraScreen }
});

const LoginStack = StackNavigator({
  Home: { screen: loginPage },
  Register: { screen: registrationPage }
});

const NavApp = StackNavigator(
  {
    loginStack: { screen: LoginStack },
    drawerStack: { screen: DrawerStack }
  },
  {
    headerMode: "none",
    initialRouteName: "loginStack",
    navigationOptions: {
      gesturesEnabled: false
    }
  }
);

export default class App extends Component {
  render() {
    return <NavApp />;
  }
}

