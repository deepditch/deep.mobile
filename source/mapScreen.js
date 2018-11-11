import React, { Component } from "react";
import {
  StyleSheet,
  Text,
  View,
  TextInput,
  TouchableOpacity,
  KeyboardAvoidingView
} from "react-native";
import { StackNavigator, DrawerNavigator } from "react-navigation";

import MapView, { AnimatedRegion } from "react-native-maps";

export default class mapScreenView extends Component {
  static navigationOptions = function(props) {
    return {
      title: "Map",
      headerLeft: (
        <TouchableOpacity onPress={() => props.navigation.openDrawer()}><Text>Menu</Text></TouchableOpacity>
      )
    };
  };

  //   constructor(props){
  //       super(props);

  //       this.state = {
  //           latitude : LATITUDE,
  //           longitude: LONGITUDE,
  //           routeCoordinates: [],
  //           distanceTravelled: 0,
  //           prevLatLng:{},
  //           coordinate: new AnimatedRegion({
  //               latitude: LATITUDE,
  //               longitude:LONGITUDE,
  //           })
  //       };
  //   }

  render() {
    return (
      <MapView
        style={style.mappingview}
        showsUserLocation
        followsUserLocation
      />
    );
  }
}

const style = StyleSheet.create({
  container: {
    flex: 1,
    padding: 25,
    backgroundColor: "#eee"
  },
  mappingview: {
    ...StyleSheet.absoluteFillObject,
    top: 10
  }
});
