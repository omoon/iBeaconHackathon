class MainController < UIViewController

  # "B9407F30-F5F8-466E-AFF9-25556B57FE6D" estimote beacon default uuid
  UUID = NSUUID.alloc.initWithUUIDString("B9407F30-F5F8-466E-AFF9-25556B57FE6D")

  def loadView
    views = NSBundle.mainBundle.loadNibNamed "Start", owner:self, options:nil
    self.view = views[0]

  end

  def viewDidLoad
    super

    @bookmarks = []

    # オリジナルのタイトルバー
    @org_title_view = self.navigationItem.titleView

    @blue_view = UIView.alloc.initWithFrame(CGRectMake(10, 10, 100, 100))
    @blue_view.backgroundColor = UIColor.blueColor

    self.view.addSubview(@blue_view)

    region = CLBeaconRegion.alloc.initWithProximityUUID(UUID, identifier: "com.lamolabo.region")

    @manager = CLLocationManager.alloc.init
    @manager.delegate = self
    @manager.startMonitoringForRegion(region)

    @label = self.view.viewWithTag 1


    #self.changeView(@button_map)

    #@button_bookmark.addTarget self, action:'changeView:', forControlEvents:UIControlEventTouchUpInside
    #@button_user = @toolbar.items[3]

  end

  def locationManager(manager, didStartMonitoringForRegion: region)
    manager.requestStateForRegion(region)
  end

  def locationManager(manager, didDetermineState: state, forRegion: region)
    if state == CLRegionStateInside
      manager.startRangingBeaconsInRegion(region)
    end
  end

  def locationManager(manager, didEnterRegion: region)
    if region.isKindOfClass(CLBeaconRegion)
      manager.startRangingBeaconsInRegion(region)
    end
  end

  def locationManager(manager, didExitRegion: region)
    if region.isKindOfClass(CLBeaconRegion)
      manager.stopRangingBeaconsInRegion(region)
    end
  end

  def locationManager(manager, didRangeBeacons: beacons, inRegion: region)
    beacon = beacons.last

    text = ''
    for beacon in beacons do
      proximity = case beacon.proximity
                  when CLProximityUnknown
                    "Unknown"
                  when CLProximityFar
                    "Far"
                  when CLProximityNear
                    "Near"
                  when CLProximityImmediate
                    "Immediate"
                  else
                    "Nothing"
                  end
      if proximity == "Immediate"
      end
      text += "#{proximity}: #{beacon.major}-#{beacon.minor} : #{beacon.rssi}\n"
    end

    @label.text = text 

    if beacon
      proximity = case beacon.proximity
                  when CLProximityUnknown
                    "Unknown"
                  when CLProximityFar
                    "Far"
                  when CLProximityNear
                    "Near"
                  when CLProximityImmediate
                    "Immediate"
                  else
                    "Nothing"
                  end
      #@label.text = "#{proximity}: #{beacon.major}-#{beacon.minor}"
    end
  end


  def tableView(tableView, numberOfRowsInSection: section)
    # return the number of rows
    @bookmarks.length
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @reuseIdentifier ||= "CELL_IDENTIFIER"

    cell = tableView.dequeueReusableCellWithIdentifier(@reuseIdentifier) || begin
      UITableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier:@reuseIdentifier)
    end

    data = @bookmarks[indexPath.row]

    puts data['fullname']

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    cell.textLabel.text = sprintf "%s(%s)", data['fullname'], data['cd']
    cell.detailTextLabel.text = '現在地から 2308m'
    cell.detailTextLabel.textColor = "#888888".to_color
    # put your data in the cell

    cell
  end

  def tableView(tableview, didSelectRowAtIndexPath: indexPath)
    data = @bookmarks[indexPath.row]
    self.showDetail data['cd']
  end

  # 検索
  def searchBarSearchButtonClicked(searchBar)
    @search_title_view.endEditing true
  end

  def changeView(id)
    if id == @button_map
      self.title = 'マップ'
      self.navigationItem.titleView = @map_title_view
      @map.hidden = false
      @bookmark.hidden = true
      @search.hidden = true

      #@button_map.enabled = false
      #@button_bookmark.enabled = true
    elsif id == @button_bookmark
      self.title = 'ブックマーク'
      self.navigationItem.titleView = @org_title_view
      @map.hidden = true
      @bookmark.hidden = false
      @search.hidden = true

      self.readBookmark
      @bookmark.reloadData

      #@button_map.enabled = true
      #@button_bookmark.enabled = false
    else
      self.title = '検索'
      self.navigationItem.titleView = @org_title_view
      @map.hidden = true
      @bookmark.hidden = true
      @search.hidden = false

      #@button_map.enabled = true
      #@button_bookmark.enabled = false
    end
  end

  def tabBar(tabBar, didSelectItem:item)
    if item.tag == 11
      self.title = 'マップ'
      self.navigationItem.titleView = @search_title_view
      @map.hidden = false
      @bookmark.hidden = true
    else
      self.title = 'ブックマーク'
      self.navigationItem.titleView = @org_title_view
      @map.hidden = true
      @bookmark.hidden = false
    end
  end

  def readBookmark
    BW::HTTP.get("http://192.168.33.11/entry14/demo00/ajax/kokoapp/271") do |response|
      @bookmarks = BW::JSON.parse(response.body.to_str)
    end
  end

  def locationManager(manager, didUpdateToLocation:newLocation, fromLocation:oldLocation)

    coordinate = newLocation.coordinate;
    @map.setCenterCoordinate coordinate, animated:false
 
    # 縮尺を設定
    zoom = @map.region
    zoom.span.latitudeDelta = 0.05
    zoom.span.longitudeDelta = 0.05
    @map.setRegion zoom, animated:true
    @map.showsUserLocation = true
 
    # 測位停止
    @locationManager.stopUpdatingLocation

    Koko::All.each { |koko| @map.addAnnotation(koko) }

  end

  def moveToCurrent(id)
    coordinate = CLLocationCoordinate2D.new
    coordinate.latitude = 34.715683 
    coordinate.longitude = 135.478089
    @map.setCenterCoordinate coordinate, animated:true
  end

  def mapView(mapView, didSelectAnnotationView:view)
     
    # 現在地のコールアウトにボタンを追加
    #if view.annotation isKindOfClass:[MKUserLocation class]] && !view.rightCalloutAccessoryView
        view.rightCalloutAccessoryView = UIButton.buttonWithType UIButtonTypeDetailDisclosure
    #end 
  end


  def mapView(map_view, annotationView:annotation_view, calloutAccessoryControlTapped:control)
    self.showDetail '27101C'
  end

  def showDetail(cd)
    controller = DetailController.alloc.initWithNibName nil, bundle: nil
    controller.cd = cd
    self.navigationController.pushViewController controller, animated: true
  end

#// 測位失敗時や、位置情報の利用をユーザーが許可しなかった場合などに呼ばれる
#- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
#{
#    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"位置情報利用不可" message:@"位置情報の取得に失敗しました。" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
# 
#    [alert show];
#}

end
