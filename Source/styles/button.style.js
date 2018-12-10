import { StyleSheet } from "react-native";

export const ButtonStyle = StyleSheet.create({
  bContainer:{
    flexDirection: 'row',
    justifyContent: 'space-between'
  },
  button: {
    backgroundColor: "#2c3443",
    paddingTop: 12,
    paddingBottom: 12,
    paddingLeft: 25,
    paddingRight: 25,
    borderRadius: 5,
    marginBottom: 25,
    alignSelf: "flex-start"
  },
  buttonText: {
    textTransform: "uppercase",
    fontWeight: "700",
    color: "#fff",
    textAlign: "center"
  },
  buttonCenter: {
    alignSelf: "center"
  },
  buttonWhite: {
    backgroundColor: "#fff",
  },
  buttonWhiteText: {
      color: "#2c3443"
  }
});
