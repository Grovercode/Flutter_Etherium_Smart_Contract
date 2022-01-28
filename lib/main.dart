import 'dart:async';

import 'package:blockchain_app/slider_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,

        visualDensity: VisualDensity.adaptivePlatformDensity,

      ),
      home: const MyHomePage(title: 'Etherium Network Transaction'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;


  @override
  State<MyHomePage> createState() => _MyHomePageState();


}

class _MyHomePageState extends State<MyHomePage> {

  late Client httpClient;
  late Web3Client ethClient;
  bool data = false;
  int myAmount = 0;
  final myAddress = "0xAF72542fb6945fe950AF41360b20483cac5cc854";

  var myData;
  var txhash;






  @override
  void initState() {
    super.initState();
    httpClient = Client();
    String url = "https://goerli.infura.io/v3/5cd3a3b6c8d14cc2b799cecde57a7e4f";
    ethClient = Web3Client(url, httpClient);
    print("initialized!");
    getBalance(myAddress);


  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Vx.white,

      body:
      ZStack([
        VxBox(
        ).blue600.size(context.screenWidth, context.percentHeight * 30).make(),

        VStack([
          (context.percentHeight * 10).heightBox,
          "HCoin".text.xl4.white.bold.center.makeCentered().py16(),
          (context.percentHeight * 5).heightBox,


          VxBox(child: VStack([
            "Balance".text.gray700.xl2.semiBold.makeCentered(),
            10.heightBox,

            data? "\$$myData".text.xl5.makeCentered().shimmer() :
                CircularProgressIndicator().centered(),

          ])).p16
              .white
              .size(context.screenWidth, context.percentHeight * 18)
              .rounded
              .shadowXl
              .make()
              .p16(),

          30.heightBox,

          SliderWidget(
            min: 0,
            max: 100,
            finalVal: (value) {
              myAmount = (value * 100).round();
              print(myAmount);
            },
          ).centered(),
          30.heightBox,

          HStack([

            new SizedBox(
              width: context.percentWidth * 30,
              height: context.percentWidth * 15,
              child:  ElevatedButton.icon(
              onPressed: () {
                getBalance(myAddress);
                print('Button Pressed');
                print(myData);

              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                textStyle: const TextStyle(fontSize: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7)),
              ),
              icon: Icon(Icons.refresh, color: Colors.white),
              label: Text("Refresh"),
            ),
            ),

            new SizedBox(
              width: context.percentWidth * 30,
              height: context.percentWidth * 15,
              child:
            ElevatedButton.icon(
              onPressed: () {
                depositCoin();
                print('Button Pressed');
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                textStyle: const TextStyle(fontSize: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7)),
              ),
              icon: Icon(Icons.call_made_outlined, color: Colors.white),
              label: Text('Deposit'),
            ),
            ),

            new SizedBox(
              width: context.percentWidth * 30,
              height: context.percentWidth * 15,
              child:        ElevatedButton.icon(
              onPressed: () {
                withdrawCoin();
                print('Button Pressed');
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
                textStyle: const TextStyle(fontSize: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7)),
              ),
              icon: Icon(Icons.call_received_outlined, color: Colors.white),
              label: Text('Withdraw'),
            ),
            ),


          ],
            alignment: MainAxisAlignment.spaceAround,
            axisSize: MainAxisSize.max,

        ).p16(),

        if(txhash!=null) txhash.toString().text.black.makeCentered()
        ]),
      ]),
    );
  }

  Future<void> getBalance(String targetAddress)  async {
    //EthereumAddress address = EthereumAddress.fromHex(targetAddress);
    List<dynamic> result = await query("getBalance", []);
    print("HELLOOOOOOOOOOOOO ");
    print("Result size is ${result.length}");
    myData = result[0];
    data = true;
    setState(() {

    });

  }

  Future<String> depositCoin() async{
    var bigAmount = BigInt.from(myAmount);

    var response = await submit("depositBalance", [bigAmount]);

    print("Deposited");
    txhash = response;
    setState(() {  });
    return response ;

  }

  Future<String> withdrawCoin() async{
    var bigAmount = BigInt.from(myAmount);

    var response = await submit("withdrawBalance", [bigAmount]);

    print("Withdrawn");
    txhash = response;
    setState(() {  });
    return response ;

  }


  Future<List<dynamic>> query (String functionName, List<dynamic> arg) async{

    final contract2 = await loadContract();
    final ethFunction = contract2.function(functionName);
    final result = await ethClient.call(contract : contract2,
    function : ethFunction, params: arg);

    return result;

  }

  Future<DeployedContract> loadContract() async {
    String abi = await rootBundle.loadString("assets/abi.json");
    String contractAddress = "0xBEa1ee063e3A0e76fEBBd26885a5e27BAc5DAA05";

    final contract = DeployedContract(ContractAbi.fromJson(abi, "PKCoin"), EthereumAddress.fromHex(contractAddress));
    return contract;
    
  }

  Future<String> submit(String functionName, List<dynamic> args) async
  {
    String Privatekey = ""; //from metamask
    EthPrivateKey credentials  = EthPrivateKey.fromHex(
      Privatekey
    );

    DeployedContract contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.sendTransaction(credentials,
        Transaction.callContract(contract: contract, function: ethFunction, parameters: args),
        fetchChainIdFromNetworkId:  true, chainId: null);

    return result;

  }

}
