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
import DamageCameraScreen from "./source/damage-camera-screen";
import mapScreenView from "./source/mapScreen";
import {
  createStackNavigator,
  createDrawerNavigator,
  DrawerItems
} from "react-navigation";

const cameraScreen = createStackNavigator(
  {
    Camera: { screen: DamageCameraScreen }
  }
  //{headerMode:"none",}
);

const mapscreen = createStackNavigator(
  {
    Map: { screen: mapScreenView }
  },
  {}
);

const DrawerStack = createDrawerNavigator(
  {
    Map: { screen: mapscreen },
    Camera: { screen: cameraScreen }
  },
  {
    initialRouteName: "Map",
    headerMode: "none",

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

const LoginStack = createStackNavigator({
  Home: { screen: loginPage },
  Register: { screen: registrationPage }
});

const DrawerNavigation = createStackNavigator(
  {
    DrawerStack: { screen: DrawerStack }
  },
  {
    headerMode: "none"
  }
);

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
    //   alert(((AuthToken)));
    //if (AuthToken === null)
    {
      //return <NavApp />;
      // return <DrawerStack/>;
    }
    //else
    {
      return <NavApp />;
      //return <DrawerStack/>;
    }
  }
}
