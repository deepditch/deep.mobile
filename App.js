import React, { Component } from "react";
import {
  StyleSheet,
  Text,
  View,
  TextInput,
  TouchableHeightlight,
  KeyboardAvoidingView
} from "react-native";

import loginPage from "./source/login/loginPage"; //import the js files you create here.
import registrationPage from "./source/login/registrationPage"; //import the js files you create here.
import DamageCameraScreen from "./source/damage-camera-screen";
import mapScreenView from "./source/mapScreen";
import { StackNavigator, DrawerNavigator } from "react-navigation";

import { PermissionsAndroid } from "react-native";

const cameraScreen = StackNavigator({
  Camera: { screen: DamageCameraScreen },
  
},
//{headerMode:"none",}
);

const mapscreen = StackNavigator({
  Map: { screen : mapScreenView},
},
{

}
);

const DrawerStack = DrawerNavigator({
  Map: { screen: mapscreen },
  Camera:{ screen: cameraScreen},
},
{
  initialRouteName: "Map",
  headerMode: "none",

}
);

const LoginStack = StackNavigator({
  Home: { screen: loginPage },
  Register: { screen: registrationPage }
});

const DrawerNavigation = StackNavigator({
  DrawerStack: {screen: DrawerStack}, 
}, 
{
  headerMode:"none",   
}
)

const NavApp = StackNavigator(
  {
    loginStack: { screen: LoginStack },
    drawerStack: { screen: DrawerNavigation }
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

