//
//  WeatherViewController.swift
//  SeSACSevenWeek
//
//  Created by Jack on 2/3/25.
//

import UIKit
import SnapKit
import MapKit

final class WeatherViewController: UIViewController {
     
    private let mapView: MKMapView = {
        let view = MKMapView()
        return view
    }()
    
    private let weatherInfoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.text = "날씨 정보를 불러오는 중..."
        return label
    }()
    
    private let currentLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "location.fill"), for: .normal)
        button.backgroundColor = .white
        button.tintColor = .systemBlue
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 4
        return button
    }()
    
    private let refreshButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        button.backgroundColor = .white
        button.tintColor = .systemBlue
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 4
        return button
    }()
    
    lazy var locationManager = CLLocationManager()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        locationManager.delegate = self
        
        
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        [mapView, weatherInfoLabel, currentLocationButton, refreshButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        mapView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(view.snp.height).multipliedBy(0.5)
        }
        
        weatherInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(mapView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        currentLocationButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.width.height.equalTo(50)
        }
        
        refreshButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.width.height.equalTo(50)
        }
    }
    
    private func setupActions() {
        currentLocationButton.addTarget(self, action: #selector(currentLocationButtonTapped), for: .touchUpInside)
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func currentLocationButtonTapped() {
        // 현재 위치 가져오기 구현
        checkDevicaLocation() // 권한 체크 후 현재 위치 설정
    }
    
    @objc private func refreshButtonTapped() {
        // 날씨 새로고침 구현
        checkDevicaLocation()
        
    }
    private func checkDevicaLocation() {
        
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled()  {// 아이폰 위치 서비스가 켜져있는지
                let authorization: CLAuthorizationStatus // 권한에 대한 상태
                if #available(iOS 14.0, *) {
                    authorization = self.locationManager.authorizationStatus
                }else {
                    authorization = CLLocationManager.authorizationStatus()
                }
                DispatchQueue.main.async {
                    self.checkCurrentLocation(status: authorization) // 권한에 대한 설정 -> 동작
                }
            }
            else {
                DispatchQueue.main.async {
                    print("아이폰의 위치 서비스가 꺼져있음")
                }
            }
        }
    }
    
    private func checkCurrentLocation(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined: // 권한에 대한 설정을 하지 않음 - > 권한 문구 띄우기
            locationManager.desiredAccuracy = kCLLocationAccuracyBest // 실제 내 위치와의 간극 조절
            locationManager.requestWhenInUseAuthorization() // 권한 문구 띄우기
            
        case .denied: // 권한 거절 -> 권한 허용 유도
            setDefaultRegion()
            showLocationSettingAlert()
        case .authorizedWhenInUse: // 권한 허용됨. -> 위치 기능 실행
            locationManager.startUpdatingLocation() // 현재 위치 가져오기
        default :
            print("오류 발생")
        }
    }
    
    private func showLocationSettingAlert() {
        self.showAlert(title: "위치 정보 이용", text: "위치 서비스를 사용할 수 없습니다. 기기의 '설정>개인정보 보호'에서 위치 서비스를 켜주세요.", button: "설정으로 이동") {
            if let setting = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(setting)
            }
        }

    }
    private func setRegionAnnotation(center: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: center, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = center
        annotation.title = "현재 위치"
        mapView.addAnnotation(annotation)
    }
    
    private func loadData(lat: Double, lon: Double) {
        NetworkManager.shared.callRequest(api: .currentWeather(lat: lat, lon: lon), type: CurrentWeather.self) { response in
            
            switch response {
            case .success(let weather):
                self.weatherInfoLabel.setWeatherInfo(temp: weather.main.temp, temp_min: weather.main.temp_min, temp_max: weather.main.temp_max, hum: weather.main.humidity, speed: weather.wind.speed)
            case .failure(let failure):
                if let errorType = failure as? NetworkError {
                    self.showAlert(title: "Error", text: errorType.errorMessage, button: nil)
                }
                else {
                    print(failure.localizedDescription)
                }
            }
        }
    }
    private func setDefaultRegion() {
        let coordinate = CLLocationCoordinate2D(latitude: 37.6543906, longitude: 127.0498832)
        setRegionAnnotation(center: coordinate)
        loadData(lat: coordinate.latitude, lon: coordinate.longitude)
    }
}
extension WeatherViewController: CLLocationManagerDelegate {
    //사용자의 위치를 성공적으로 가져온 경우
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let coordinate = locations.last?.coordinate {
            setRegionAnnotation(center: coordinate)
            loadData(lat: coordinate.latitude, lon: coordinate.longitude)
        } else {
            
            setDefaultRegion()
        }
        locationManager.stopUpdatingLocation() // 더이상 위치를 안받아도 되는 시점..?
        
    }
    
    //사용자의 위치를 성공적으로 가져오지 못한 경우
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        //default위치 설정
        setDefaultRegion()
    }
    // 권한 상태가 변경되었을 때, locationManager 인스턴스가 생성될 때
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkDevicaLocation()
    }
    
    // ios 14미만
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkDevicaLocation()
    }
}
