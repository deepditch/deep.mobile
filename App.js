import React, { Component } from "react";
import {
  StyleSheet,
  Text,
  View,
  TextInput,
  TouchableOpacity,
  KeyboardAvoidingView,
  SafeAreaView,
  Button,
  Alert

} from "react-native";
import { AsyncStorage } from "react-native";
import loginPage from "./Source/Login/loginPage"; //import the js files you create here.
import registrationPage from "./Source/Login/registrationPage"; //import the js files you create here.
import DamageCameraScreen from "./Source/damage-camera-screen";
import mapScreenView from "./Source/mapScreen";
import { StackNavigator, DrawerNavigator, DrawerItems } from "react-navigation";

import { PermissionsAndroid } from "react-native";
import AuthService from "./Source/services/auth.service";

const cameraScreen = StackNavigator({
  Camera: { screen: DamageCameraScreen },

},
  //{headerMode:"none",}
);

const mapscreen = StackNavigator({
  Map: { screen: mapScreenView },
},
  {

  }
);

const DrawerStack = DrawerNavigator({
  Map: { screen: mapscreen },
  Camera: { screen: cameraScreen },
},
  {
    initialRouteName: "Map",
    headerMode: "none",

    contentComponent: (props) => (
      <View style={{ flex: 1 }}>

        <SafeAreaView forceInset={{ top: 'always', horizontal: 'never' }}>
          <DrawerItems{...props} />
          <TouchableOpacity onPress={() => Alert.alert(
            'Logout',
            'Are you sure you want to logout?',
            [
              {
                text: 'Yes', onPress: () => {
                  AsyncStorage.getAllKeys().then(AsyncStorage.multiRemove);
                  props.navigation.navigate('Home')
                }
              },
              {
                text: 'Cancel', onPress: () => { return null }
              },
            ],
          )
          }>
            <Text style={{ margin: 16, fontWeight: 'bold' }}>Logout</Text>
          </TouchableOpacity>
        </SafeAreaView>

      </View>
    )
  }

);

const LoginStack = StackNavigator({
  Home: { screen: loginPage },
  Register: { screen: registrationPage }
});

const DrawerNavigation = StackNavigator({
  DrawerStack: { screen: DrawerStack },
},
  {
    headerMode: "none",
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