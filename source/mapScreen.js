import React, { Component } from "react";
import {
  StyleSheet,
  Text,
  View,
  TextInput,
  TouchableOpacity,
  Button,
  KeyboardAvoidingView
} from "react-native";
import { StackNavigator, DrawerNavigator } from "react-navigation";

import MapView, { AnimatedRegion } from "react-native-maps";

export default class mapScreenView extends Component {
  static navigationOptions = function (props) {
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
      <View style={style.container}>
        <MapView
          style={style.mappingview}
          showsUserLocation
         // followsUserLocation
        >
        <MapView.Marker coordinate={{latitude:37,
        longitude:-100}}/>
        </MapView>
      </View>
    );
  }

}

const style = StyleSheet.create({
  container: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    justifyContent: 'flex-end',
    alignItems: 'center',
  },

  mappingview: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
  },
});

