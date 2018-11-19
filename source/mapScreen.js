import React, { Component } from "react";
import { StyleSheet, Text, View, TouchableOpacity, Image } from "react-native";
import MapView, { AnimatedRegion } from "react-native-maps";
import DamageService from "./services/damage.service";


const imageUrls = {
  "D00": require("../images/pins/D00.png"),
  "D01": require("../images/pins/D01.png"),
  "D10": require("../images/pins/D10.png"),
  "D11": require("../images/pins/D11.png"),
  "D20": require("../images/pins/D20.png"),
  "D40": require("../images/pins/D40.png"),
  "D43": require("../images/pins/D43.png"),
  "D44": require("../images/pins/D44.png"),
}

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
    this.getDamageMarkers();
  }

  getDamageMarkers = () => {
    console.log("DamageService: ", DamageService);
    new DamageService().getDamages().then(damages => {
      var positions = damages.map(damage => {
        return {
          position: {
            latitude: damage.position.latitude,
            longitude: damage.position.longitude
          },
          id: damage.id,
          type: damage.type
        };
      });
      console.log("Positions: ", positions);

      this.setState({ markersPositions: positions });
    });
  };

  render() {
    const damageMarkers = this.state.markersPositions.map(markerPosition => (
      <MapView.Marker
        coordinate={markerPosition.position}
        key={markerPosition.id}
      >
        <Image source={imageUrls[markerPosition.type]} />
      </MapView.Marker>
    ));

    console.log(damageMarkers);

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
