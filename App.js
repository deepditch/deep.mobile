import React, { Component } from "react";
import {
  StyleSheet,
  Dimensions,
  Text,
  TouchableOpacity,
  Alert,
  Platform,
  View
} from "react-native";
import loginPage from "./source/login/loginPage"; //import the js files you create here.
import { StackNavigator } from "react-navigation";
import DamageCamera from "./damage-camera";
import DamageService from "./source/services/damage.service";
import { ButtonStyle } from "./source/styles/button.style";
import { PermissionsAndroid } from "react-native";
import AuthService from "./source/services/auth.service";

class DamageLabels extends Component {
  render() {
    return (
      <>
        {this.props.labels &&
          this.props.labels.map(label => (
            <Text style={styles.capture}>{label}</Text>
          ))}
      </>
    );
  }
}

class CameraScreen extends Component {
  static navigationOptions = {
    title: "Camera"
  };

  state = {
    token: null,
    damages: []
  };

  constructor(props) {
    super(props);
  }

  componentDidMount() {
    if (Platform.OS === "ios") {
      //platform.OS detects if it ios or android and runs the respective permissions
      navigator.geolocation.requestAuthorization(); //so that both ios and android receives the right permissions and both work at the same time.
    } else {
      requestPermissions();
    }

    new AuthService().getToken(token => {
      this.setState({
        token: token
      });
    });
  }

  _onDamageDetected(event) {
    this.setState({ damages: event.damages });
    console.log(this.state.damages, this.state, event.damages);
  }

  render() {
    if (!this.state.token) {
      return (
        <View>
          <Text>Loading...</Text>
        </View>
      );
    }

    return (
      <DamageCamera
        style={styles.preview}
        onDamageDetected={this._onDamageDetected.bind(this)}
        authToken={this.authToken}
      >
        <DamageLabels labels={this.state.damages} />
      </DamageCamera>
    );
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
