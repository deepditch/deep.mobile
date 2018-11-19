import React, { Component } from "react";
import { StyleSheet, Text, View, TouchableOpacity, Button } from "react-native";
import MapView, { AnimatedRegion } from "react-native-maps";
import DamageService from "./services/damage.service";

export default class mapScreenView extends Component {
  static navigationOptions = function(props) {
    return {
      title: "Map",
      headerLeft: (
        <TouchableOpacity onPress={() => props.navigation.openDrawer()}>
          <Text>Menu</Text>
        </TouchableOpacity>
      )
    };
  };

  state = {
    markersPositions: []
  };

  componentDidMount() {
    this.getDamageMarkers()
  }

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

  getDamageMarkers = () => {
    console.log("DamageService: ", DamageService);
    new DamageService().getDamages().then(damages => {
      var positions = damages.map(damage => {
        return {
          position: {
            latitude: damage.position.latitude,
            longitude: damage.position.longitude,
          },
          id: damage.id
        };
      });
      console.log("Positions: ", positions);

      this.setState({ markersPositions: positions });
    });
  };

  render() {
    const damageMarkers = this.state.markersPositions.map(markerPosition => (
      <MapView.Marker coordinate={markerPosition.position} key={markerPosition.id} />
    ));

    console.log(damageMarkers)

    return (
      <View style={style.container}>
        <MapView
          style={style.mappingview}
          showsUserLocation
          followsUserLocation
        >
          {damageMarkers}

        </MapView>
      </View>
    );
  }
}

const style = StyleSheet.create({
  container: {
    position: "absolute",
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    justifyContent: "flex-end",
    alignItems: "center"
  },

  mappingview: {
    position: "absolute",
    top: 0,
    left: 0,
    right: 0,
    bottom: 0
  }
});
