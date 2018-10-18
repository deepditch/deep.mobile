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

//===================Android Permissions=====================================//
/*
//Following permissions is needed to run the app on the android version.
//Code below is android specific. You shouldn't need to comment it out to get it work on ios,
//as I have fixed the issue on componentdidmount() with the if statement and platform.os so
//that it detects the proper os and runs their respective version of the code for permissions.
// function below can be moved to its own js file but I will keep it here for now.
*/
async function requestPermissions() {
  try {
    const granted = await PermissionsAndroid.requestMultiplePermissions([
      //PermissionsAndroid.PERMISSIONS.geolocation,

      PermissionsAndroid.PERMISSIONS.CAMERA,

      PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION,

      PermissionsAndroid.PERMISSIONS.ACCESS_COARSE_LOCATION,

      PermissionsAndroid.PERMISSIONS.WRITE_EXTERNAL_STORAGE,

      PermissionsAndroid.PERMISSIONS.READ_EXTERNAL_STORAGE
    ]);
    if (granted === PermissionsAndroid.RESULTS.GRANTED) {
      console.log("Permission granted");
    } else {
      console.log("Permission denied");
    }
  } catch (err) {
    console.warn(err);
  }
}
//===================================================================================

export default class App extends Component {
  render() {
    return <NavApp />;
  }
}

