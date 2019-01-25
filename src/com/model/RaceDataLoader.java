package com.model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import com.pckeiba.racedata.RaceDataLoad;
import com.pckeiba.racedata.RaceDataSet;
import com.pckeiba.umagoto.UmagotoDataIndexLoad;
import com.pckeiba.umagoto.UmagotoDataLoad;
import com.pckeiba.umagoto.UmagotoDataSet;
import com.pckeiba.umagoto.UmagotoDrunLoad;
import com.pckeiba.umagoto.UmagotoDrunSet;

public class RaceDataLoader implements Serializable{
	/**
	 *
	 */
	private static final long serialVersionUID = 1L;

	private String raceCode;
	private int hit;
	private RaceDataSet rds;
	private List<UmagotoDataSet> umaList;
	private List<Map<String,UmagotoDataSet>> umaMapList;
	private UmagotoDataLoad umaLoad;
	private Map<Integer,UmagotoDataSet> kakoRaceDataMap;
	private Map<String,UmagotoDrunSet> drunList;
	private List<UmagotoDrunSet> drunSortList;
	private UmagotoDataIndexLoad indexLoad;

	public RaceDataLoader() {}

	public RaceDataLoader(String raceCode, int hit) {
		this.raceCode = raceCode;
		this.hit = hit;
		setRaceDataSet(raceCode,hit);
	}

	public String getRaceCode() {
		return raceCode;
	}

	public void setRaceCode(String raceCode) {
		this.raceCode = raceCode;
		setRaceDataSet(raceCode,hit);
	}

	public int getHit() {
		return hit;
	}

	public void setHit(int hit) {
		this.hit = hit;
		setRaceDataSet(raceCode,hit);
	}

	public void setRaceData(String raceCode, int hit) {
		this.raceCode = raceCode;
		this.hit = hit;
		setRaceDataSet(raceCode,hit);
	}

	/**
	 * コンストラクタ<br>レースコードで指定されたレースデータをダウンロードします。
	 * @param raceCode レースコード
	 * @param hit 過去走レース数
	 */
	public void setRaceDataSet(String raceCode, int hit) {

		hit++;
		//レース詳細データをダウンロードする
		RaceDataLoad raceLoad = new RaceDataLoad(raceCode);
		rds = raceLoad.getRaceDataSet();

		//馬毎データをダウンロードする
		drunList = new UmagotoDrunLoad(raceCode).getDrunList();
		umaLoad = new UmagotoDataLoad(raceCode,hit);
		umaList = umaLoad.getList().stream().filter(s -> s.getUmaID()==1).collect(Collectors.toList());
		umaMapList = new ArrayList<>();
		drunSortList = new UmagotoDrunLoad(raceCode).getDrunSortList();
		for(int i=2; i<=hit;i++) {
			umaMapList.add(umaLoad.getMapFromKettoTorokuBango(i));
		}
		indexLoad = new UmagotoDataIndexLoad(raceCode, 4);
	}

	/**
	 * レース詳細データのオブジェクトを返します。
	 * @return レース詳細オブジェクト
	 */
	public RaceDataSet getRaceDataSet() {
		return rds;
	}

	/**
	 * 今走の馬毎詳細データのオブジェクトをリスト形式で返します。
	 * @return 今走の馬毎詳細オブジェクトリスト
	 */
	public List<UmagotoDataSet> getNowRaceDataList() {
		return umaList;
	}

	/**
	 * 過去走の馬毎データのオブジェクトをマップリスト形式で返します。
	 * @return 過去走の馬毎詳細オブジェクトのマップリスト
	 */
	public List<Map<String, UmagotoDataSet>> getKakoRaceDataMapList() {
		return umaMapList;
	}

	/**
	 * 指定された過去走データをマップ形式で返します。<br>マップのキーは今走の馬番です。
	 * @param race 指定過去走
	 * @return 過去走の馬毎詳細オブジェクトのマップ
	 */
	public Map<Integer,UmagotoDataSet> getKakoRaceDataMap(int race){
		kakoRaceDataMap = umaLoad.getMap(++race);
		return kakoRaceDataMap;
	}

	public Map<String,UmagotoDrunSet> getDrunList() {
		return drunList;
	}

	public UmagotoDataLoad getUmaLoad() {
		return umaLoad;
	}

	public List<UmagotoDrunSet> getDrunSortList() {
		return drunSortList;
	}

	public void setDrunSortList(List<UmagotoDrunSet> drunSortList) {
		this.drunSortList = drunSortList;
	}

	/**
	 * @return 馬毎指数リスト
	 */
	public UmagotoDataIndexLoad getIndexLoad() {
		return indexLoad;
	}


}
