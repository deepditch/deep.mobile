import React, { Component } from "react";
import {
  StyleSheet,
  Text,
  View,
  TextInput,
  TouchableOpacity,
  KeyboardAvoidingView,
  Button,

} from "react-native";
import { StackNavigator, DrawerNavigator } from "react-navigation";

import MapView, { AnimatedRegion } from 'react-native-maps';

export default class mapScreenView extends Component {
  static navigationOptions = function(props) {
    return{
        title: "Map",
     headerLeft:
  <Text onPress={()=>props.navigation.openDrawer()}>Menu</Text>
};}

state={
  MarkerPositions:[]
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



// async mapMarker() {
//   const data = {
//   };

//   const config = {
//     headers: {
//       Accept: "application/json",
//       "Content-Type": "application/json",
//      // "x-requested-with": "XMLHttpRequest"
//     },
//     body: JSON.stringify(data)
//   };

//   return new Promise((resolve, reject) => {
//     fetch("http://216.126.231.155/api/road-damage", config)
//       .then(this.parseJSON)
//       .then(response => {
//         if (!response.ok) return reject(response.json);
//         this.setToken(response.json.access_token);
//         return resolve(response.json);
//       });
//   });
// }



// ON button press supposed to run this
getDamagesHandler=()=>{
  fetch("http://216.126.231.155/api/road-damage") //get the response from api
  .then(res=>res.json())
  .then(parsedRes=>{
    const MapMarkerArray =[]; //array to store the positions and loop through. 
    for(const key in parsedRes){    
      MapMarkerArray.push({                 
        latitude: parsedRes[key].latitude,
        longitude: parsedRes[key].longitude,
        id:key
      });
    }
    this.setState({
      MarkerPositions:MapMarkerArray
    })
  })
};

  render() {
    // a button to get the cords and place markers when pressed.
    <View>
    <Button title="Get Damages" onPress={this.getDamagesHandler}/> 
  </View>
  const MarkersP = props.MarkerPositions.map(markerPosition =>(  // markerpositions supposed to have the coords, lat/lang
    <MapView.Marker coordinate = {markerPosition} key ={userPlace.id}/>
  ));
    return (
      <MapView style={style.mappingview} //MarkersP is supposed to mark the the map with pins
      showsUserLocation
      followsUserLocation>
       {MarkersP}           
      </MapView>


    );
  }

}

const style = StyleSheet.create({
  container: {
    flex: 1,
    padding: 25,
    backgroundColor: "#eee"
  },
  mappingview:{
      ...StyleSheet.absoluteFillObject,
      top:10,
  }
});