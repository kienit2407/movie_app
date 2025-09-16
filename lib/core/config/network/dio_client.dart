import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:http_cache_hive_store/http_cache_hive_store.dart';
import 'package:movie_app/common/helpers/contants/app_url.dart';
import 'package:movie_app/core/errol/app_exception.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
//giảm gọi api nhiều lần trong cùng 1 session khi di chuyển qua lại giữa các tag
class DioClient {
  // static final DioClient _instance = DioClient._internal(); // tạo  biến thuộc class, chỉ khởi tạo 1 lần, và khi tạo instance lần đầu nó sẽ lưu 1 instance vào bộ nhớ duy nhất

  // factory DioClient() => _instance; // khi gọi lần sau nó sẽ trả về cùng instance, factory trả về 1 đối tuọng có sẵn
  static const int _connectTimeout = 30000; // thời gian để kết nối
  static const int _receiveTimeout = 30000; // thời gian để nhận kết nối
  static const int _sendTimeout = 30000; // thời gian để gửi đi post

  // nhận assessToken và refreshToken
  String? _accessToken; // do là accessToken có thể thay đổi khi chạy chương trình
  String? _refreshToken;
 
  //Mình bị lỗi lazyInit nghĩa là khai báo late mà không gán giá trị, hàm là future nhưng không thể async nên lỗi 

  late final CacheOptions _cacheOptions; // khai báo biến cachingOption để áp dụng cho mọi request

    //HANDLE CALLING API 
  late final Dio _dio; //khởi tạo 1 lần và không thể thay đổi
  //late cho phép đối tượng khởi tạo sau khi DioClient khởi tạo (late cho phép gán giá trị sau khi khởi tạo đối tượng. Nhưng do khởi tạo đối tượng Dio rất tốn tài nguyên ví dụ kết nối mạng,.. )
  //_dio <- biến private cho phép sử dụng trong lớp DioClient thôi
  // nếuu biến được khia báo là final mà không được gán giá trị ban đầu hoặc contructor thì sẽ bị lỗi compile
  // DioClient({String? baseUrl}) : _dio = Dio(
  // ); -> đây là initilize list, do là nếu không có late thì nó phỉa được gán trong contruct hoặc trong initilize list
  // DioClient._internal //-> khai báo contructor private đẻ không có lớp bên ngoài, và chỉ tạo đúng 1 lần để tạo instance
  // ({String? baseUrl}) { // phải đảm bảo Dio được khởi tạo trước khi sử dụng các phương thức khác. nó áp dụng cho các request khác không làm lặp code 

  //khai báo một factory contructor -> nó sẽ trả về instance theo singleton
  static Future<DioClient> create({String? baseUrl}) async {
    final client = DioClient._internal();
    await client.initalizeCacheOption(baseUrl: baseUrl);
    client._initDio();
    return client;
  } 

// Constructor private, không init gì
  DioClient._internal();
    //khởi tạo instance dio
  void _initDio({String? baseUrl}) {
        
      _dio = Dio(); //gán trước -> lí do là do dio nếu dùng cacade thì interceptor đều khỏi tạo cùng 1 cùng nhưng mà. do là trong interceptor cần instance của dio nhưng khi khai báo như vậy nó khởi tạo không kịp gây ra lỗi. Nên giải pháp là [gán trước rồi cho nó gán từng cái base option và interceptor lần lượt]
      _dio.options = BaseOptions( // dùng để cấu hình các thiết lập mặc định ban đầu cho "tất cả request", giúp cần lặp lại cho từng req
        baseUrl: baseUrl ?? AppUrl.baseUrl,
        connectTimeout: Duration(milliseconds: _connectTimeout), // đây là thời gian mà client kết nối đến server nếu quá timeout thì sẽ báo lỗi timeout. Ngăn ứng dụng treo, server không phản hồi, đảm bảo trải nghiệm khi có lỗi thì show ra không để đợi lâu
        receiveTimeout: Duration(milliseconds: _receiveTimeout), //Nếu mà đã kết nối với server rồi nhưng thời gian truyền dữ liệu be timeouted thì cũng sẽ quăng lỗi. Tránh ứng dụng bị treo và bảo vệ ứng dựng khi sever phản hồi chậm, hoặc có vấn đề
        sendTimeout: Duration(milliseconds: _sendTimeout),//-> thời gian gửi lên tương tự 2 cái kia
        headers: {//chuẩn hoá header, giảm lặp code cho mỗi req
          'Content-Type': 'application/json',  //Khi gửi đi thì baseOption này sẽ nhét vào req yêu cầu gửi đi là 1 file dạng json
          'Accept': 'application/json', //tương tự khi get về cũng expectn là 1 dạng json báo cho server biết
          // 'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36', //giả lập yêu cầu được gửi từ trình duyệt
          // 'Referer': 'https://phimapi.com'
          
        },
        responseType: ResponseType.json, //định dạng dữ liệu dio mặc định là json rồi. Alternative, nó còn những dữ liệu khác byte cho file, plain cho text
        validateStatus: (status) {
          return status != null && status >= 200 && status < 300; // kiểm status code mà server trả về
        },
      );
      _dio.interceptors.addAll([ // là một hàm để ngăn chặn, bộ lọc giữa req va res
        DioCacheInterceptor(options: _cacheOptions), //đặt ở đầu tiên để cache response. Đẩm bảo dữ liệu được cache nagy khi nhận từ server
        // _AuthInterceptor(this),

        //retry khi when requesting is failed
        RetryInterceptor( //-. cái này đã đủ kích hoạt cache cho mọi request rồi
          dio: _dio, //nhận vào dio để control việc retry khi bị fail 
          logPrint: (message) => print('[Retry]: $message'),
          retries: 3, // -> số lần retry
          retryDelays: [
            Duration(seconds: 1), //lần 1 đợi 1s
            Duration(seconds: 1), //lần 1 đợi 1s
            Duration(seconds: 1), //lần 1 đợi 1s
          ],
          retryEvaluator: (error, attempt) { //-> Chỉ retry với các lỗi network 
            if(
              error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.sendTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.connectionError
              ){
                return true;
              }
            if(error.response?.statusCode != null) {
              final statusCode = error.response!.statusCode!;
              return statusCode >= 500 && statusCode < 600; //chỉ retry khi lỗi 500 là lỗi kết nối mạng
            }
            return false;
            //mục đích thử lại khi failed that relate to sever or network 
          },
        ),
      // đặt cuối để hiện các log khac nhau req và res kể cả là log của retry -> that one of reason why it locate back of all
        PrettyDioLogger(
          requestHeader: true, // kiểm tra xem header gửi đi có đúng không
          requestBody: true, // kiểm tra dữ liệu gửi lên server có đúng định dạng hay không
          responseBody: true, // kiểm tra dữ liệu trả về có đúng hay không
          responseHeader: false, // dài và không cần thiết để debug
          error: true, // in ra lỗi khi req bị lỗi quăng dio Exception
          compact: true, //loh hiển thị trẻnq dòng , không xuống dòng quá nhiều tránh khó đọc
          maxWidth: 90 // tối đa của mỗi dòng log la 90 kí tự
        )
      ]) ;
        print('Initalized dioInterceptor');
  }
  Future<void> initalizeCacheOption ({String? baseUrl}) async {
    
    // final cacheDirectory = await getTemporaryDirectory(); // TRẢ VỀ ENDPOINT for using temporary data or api 
    //getAplication thì trả về danh mục lưu trữ lưu dà
    print('Initalized cache option');

    //set up cache option 
    _cacheOptions = CacheOptions(
      // store: HiveCacheStore(cacheDirectory.path),
      store: MemCacheStore(), // Có thể thay bằng HiveCacheStore() cho persistent cache
      //memCache nó là mặc định của flutter (Nhưng nó sẽ lưu cache và bộ nhớ ram của thiết bị)
      // còn Hive thì nó lưu cache lâu hơn
      policy: CachePolicy.request, //quy định cached -> kiêm tra cache. Nếu cache còn hạn (still value) trả dữ liệu của cache còn không thì gửi request mới cho server
      hitCacheOnErrorCodes: [401, 403, 500, 502, 503, 504], //nếu lỗi 500 (lỗi do server thì sẽ "sử dụng cache").Otherwise, còn nếu lỗi 401 (unauthorized -> lỗi uỷ quyền) và 403 (Forbiden) -> lỗi bị cấm
      maxStale: Duration(minutes: 1), // cái này set chung cho mọi request nhưng tuỳ call api thì thời gian sẽ khác có thể ghi đè lai
      priority: CachePriority.normal, // về mức độ ưu tiên nếu normal thì nếu ram đầy thì nó sẽ tự động xoá đi 
      cipher: null, //mã hoá dữ liệu, nếu muôn hoá dữ liệu để lưu vào cache có thể sử dụng encrypt. Null -> lưu dưới dạng plain text. cái này dùng cho token
      keyBuilder: CacheOptions.defaultCacheKeyBuilder, //tạo khoá key cho cached dauw vào url và query paramaters của request, đảm bảo mỗi request là duy nhất và giúp dio truy xuất đúng
      allowPostMethod: false,// không cache post url
      hitCacheOnNetworkFailure: true //sử dụng cache khi bị lỗi mạng
    );
  }
  // //Dùng trong code dioClient.dio.get
  Dio get dio => _dio; // getter để có thể truy cập dio từ lớp bên ngoài (readOnly not set because we can not replace any data in this class) .. nếu các lớp bên ngoài truy cập tuỳ tiện từ bên ngoài có thể làm hỏng config
  // //triển khai phương thức get
  Future<Response> get (
    {
      required String path, //bắt buộc truyền vào đường dẫn 
      Map<String, dynamic>? queryParameters,
      Options? option,
    }
  ) async {
    try {
      final response = await _dio.get(
        path,
        options: option, // để overide option
        queryParameters: queryParameters, // truyền các tham số query sau dấu ?
      ); //truyền vào path
      
      return response;
    } on DioException catch (e) {
      throw _handlingErrol(e);
    }
  }
  //triển khai phương thức post
  Future<Response> post (
    String path,
    {
      dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? option
    }
  ) async {
    try {
      final response = await _dio.post(
        path,
        data: data, // dữ liệu gửi đi trong body cua req
        options: option,
        queryParameters: queryParameters // ví dụ post lên dựa theo userid chẳng hạn
      );
      return response;
    } on DioException catch (e) {
      throw _handlingErrol(e);
    }
  }

  Exception _handlingErrol (DioException error) { 
    switch (error.type) { // tạo một switch
      case DioExceptionType.connectionError:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return NetworkException('Connection timeout');
      case DioExceptionType.badResponse:
        switch (error.response?.statusCode) {
          case 400:
            return BadRequestException('Bad Request'); // lỗi yêu cầu
          case 401:
            return UnauthorizedException('Unauthorized'); // lỗi xác thực
          case 404: 
            return NotFoundException('Not Found'); // lỗi không tìm thấy trang
          case 500:
            return ServerException('Internal server errol'); // lỗi bên trong server
          default:
            return ServerException('Server has error'); // lỗi server 
        }
      default: 
        return NetworkException('A Error occured with Network'); // lỗi mạng
    }
  }
}
// 408: RequestTimeout
// 429: TooManyRequests
// 500: InternalServerError
// 502: BadGateway
// 503: ServiceUnavailable
// 504: GatewayTimeout
// 440: LoginTimeout (IIS)
// 460: ClientClosedRequest (AWS Elastic Load Balancer)
// 499: ClientClosedRequest (ngnix)
// 520: WebServerReturnedUnknownError
// 521: WebServerIsDown
// 522: ConnectionTimedOut
// 523: OriginIsUnreachable
// 524: TimeoutOccurred
// 525: SSLHandshakeFailed
// 527: RailgunError
// 598: NetworkReadTimeoutError
// 599: NetworkConnectTimeoutError It's possible to override this list

//Explaining the log below:
// flutter: Initalized cache option -> xác nhận cache đã được khỏi tạo
// flutter: Initalized dioInterceptor
// flutter: supabase.supabase_flutter: INFO: ***** Supabase init completed *****
// flutter: Khởi tạo thành công
// flutter:
// flutter: ╔╣ Request ║ GET
// flutter: ║  https://phimapi.com/danh-sach/phim-moi-cap-nhat-v3?page=1
// flutter: ╚══════════════════════════════════════════════════════════════════════════════════════════╝
// flutter: ╔ Query Parameters
// flutter: ╟ page: 1
// flutter: ╚══════════════════════════════════════════════════════════════════════════════════════════╝
// flutter: ╔ Headers
// flutter: ╟ Content-Type: application/json
// flutter: ╟ Accept: application/json
// flutter: ╟ contentType: application/json
// flutter: ╟ responseType: ResponseType.json
// flutter: ╟ followRedirects: true
// flutter: ╟ connectTimeout: 0:00:30.000000
// flutter: ╟ receiveTimeout: 0:00:30.000000
// flutter: ╚══════════════════════════════════════════════════════════════════════════════════════════╝
// flutter: ╔ Extras
// flutter: ╟ cacheOptions: Instance of 'CacheOptions'
// flutter: ╟ @requestSentDate@: 2025-09-05 15:05:15.571084
// flutter: ╚══════════════════════════════════════════════════════════════════════════════════════════╝
// flutter:
// flutter: ╔╣ Response ║ GET ║ Status: 200 OK  ║ Time: 928 ms
// flutter: ║  https://phimapi.com/danh-sach/phim-moi-cap-nhat-v3?page=1
// flutter: ╚══════════════════════════════════════════════════════════════════════════════════════════╝
// flutter: ╔ Body
// flutter: ║