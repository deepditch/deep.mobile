import React, { Component } from "react";
import {
  StyleSheet,
  Text,
  View,
  TextInput,
  TouchableOpacity,
  TouchableHighlight,
  Button,
  KeyboardAvoidingView
} from "react-native";
import { StackNavigator, DrawerNavigator } from "react-navigation";
import config from "../project.config"; 
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
state={
  markersPositions:[]
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

getDamageMarkeres=()=>{
  
  const requestBody = {
    method: "GET",
    headers: {
      "Content-Type": "application/json",
      authorization:"Bearer " + "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vMjA5LjEyNi4zMC4yNDcvYXBpL2xvZ2luIiwiaWF0IjoxNTQyNjQwNDQzLCJleHAiOjE1NDI2NDQwNDMsIm5iZiI6MTU0MjY0MDQ0MywianRpIjoiN2hSaWdYclVlQVE4QTR1eCIsInN1YiI6MjIsInBydiI6Ijg3ZTBhZjFlZjlmZDE1ODEyZmRlYzk3MTUzYTE0ZTBiMDQ3NTQ2YWEifQ.xxY6YTBJ960p_a03YmraDFmRvbjlSqdeiz3tyf6L3mw"
      },
    //body: JSON.stringify(data)
  };

  fetch(config.API_BASE_PATH+"/road-damage", requestBody)
  .then(res=>res.json())
  .then(parsedRes=>{
    console.log((parsedRes))
    const markersArray=[];
    for(const key in parsedRes)
    {
      markersArray.push({
        position: parsedRes[key].position,
        
        id:key
      })
      console.log(position);
    }
    this.setState({
      markersPositions:markersArray
    })
  })
}
  
  render() {
    markersPositions = this.state.markersPositions;
const damageMarkers = markersPositions.map(markerPosition=> (
<MapView.Marker coordinate = {markerPosition} key= {markerPosition.id}/>
));
    return (
      <View style={style.container}>
     
        <MapView
          style={style.mappingview}
          showsUserLocation
         // followsUserLocation
        >
        {damageMarkers}
        <MapView.Marker coordinate={{latitude:37,
        longitude:-100}}/>
        </MapView>
        <View style={{position:"absolute",top:'90%', alignItems:"center"}}>
            <Button title="Get damage locations" onPress={this.getDamageMarkeres.bind(this)}/>
          </View>
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

