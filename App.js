import React, { Component } from "react";
import {
  Text,
  View,
  TouchableOpacity,
  SafeAreaView,
  Alert
} from "react-native";
import { AsyncStorage } from "react-native";
import loginPage from "./source/login/loginPage"; //import the js files you create here.
import registrationPage from "./source/login/registrationPage"; //import the js files you create here.
import forgotPasswordPage from "./source/login/forgotPassword";
import DamageCameraScreen from "./source/damage-camera-screen";
import mapScreenView from "./source/mapScreen";
import {
  createStackNavigator,
  createDrawerNavigator,
  DrawerItems
} from "react-navigation";

/*
App.js mostly used for stack navigation and drawer navigation. Modify codes in this file 
if you want to add diffrent screen to drawer menu, or more navigation on the login menu. 
*/

// for each screen in drawer menu, have create a new stack. Examples are below

const cameraScreen = createStackNavigator(    //creates a camera screen stack.
  {
    Camera: { screen: DamageCameraScreen }      // it is named Camera, so when navigation you use Camera to navigate to camera screen.
  },
  //{headerMode:"none",}
);

const mapscreen = createStackNavigator(
  {
    Map: { screen: mapScreenView }
  },
  {}
);
                                              //DrawerStack add screens to show on the drawer.
const DrawerStack = createDrawerNavigator(
  {
    Camera: { screen: cameraScreen },
    Map: { screen: mapscreen },

  },
  {
    initialRouteName: "Camera",                 // Screen that will be displayed first when stack is called
    headerMode: "none",
                                                //to add items in the drawer like buttons use contentComponents.
                                                // below is an example of logout.
    contentComponent: props => (                         
      <View style={{ flex: 1 }}>                         
        <SafeAreaView forceInset={{ top: "always", horizontal: "never" }}>
          <DrawerItems {...props} />
          <TouchableOpacity
            onPress={() =>
              Alert.alert("Logout", "Are you sure you want to logout?", [
                {
                  text: "Yes",
                  onPress: () => {
                    AsyncStorage.getAllKeys().then(AsyncStorage.multiRemove);
                    props.navigation.navigate("Home");
                  }
                },
                {
                  text: "Cancel",
                  onPress: () => {
                    return null;
                  }
                }
              ])
            }
          >
            <Text style={{ margin: 16, fontWeight: "bold" }}>Logout</Text>
          </TouchableOpacity>
        </SafeAreaView>
      </View>
    )
  }
);

// Create any screen that you don't want the user to have access after login in the LoginStack.

const LoginStack = createStackNavigator({
  Home: { screen: loginPage },                          //opens up the login screen from ./source/login/loginPage
  Register: { screen: registrationPage },
  ForgotPass: { screen: forgotPasswordPage }
});

const DrawerNavigation = createStackNavigator(          
  {
    DrawerStack: { screen: DrawerStack }
  },
  {
    headerMode: "none"
  }
);
                                                      // main navigator stack, has to load to have full access.
const NavApp = createStackNavigator(
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



