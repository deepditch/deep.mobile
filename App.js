import React, { Component } from "react";
import { Platform, StyleSheet, Text, Dimensions, View } from "react-native";
import loginPage from "./Source/Login/loginPage"; //import the js files you create here.
import { StackNavigator } from "react-navigation";
import Camera from "react-native-camera";

class HomeScreen extends React.Component {
  static navigationOptions = {
    title: "Home"
  };
  render() {
    const { navigate } = this.props.navigation;
    return (
      <View style={styles.homeFormat}>
        <Text onPress={() => navigate("Camera")}> GO TO CAMERA.</Text>
      </View>
    );
  }
}

class CameraScreen extends React.Component {
  static navigationOptions = {
    title: "Camera"
  };
  render() {
    const { navigate } = this.props.navigation;
    return (
      <Camera
        ref={cam => {
          this.camera = cam;
        }}
        style={styles.preview}
        aspect={Camera.constants.Aspect.fill}
      >
        <Text style={styles.capture} onPress={this.takePicture.bind(this)}>
          {" "}
          [CAPTURE]{" "}
        </Text>
      </Camera>
    );
  }

  takePicture() {
    this.camera
      .capture()
      .then(data => console.log(data))
      .catch(err => console.error(err));
  }
}

const NavApp = StackNavigator({
  Home: { screen: HomeScreen },
  Camera: { screen: CameraScreen }
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
  },
  capture: {
    flex: 0,
    backgroundColor: "#ffffff",
    borderRadius: 5,
    color: "#000",
    padding: 10,
    margin: 40
  }
});
