package com.model;

import java.io.IOException;
import java.io.Serializable;

import com.example.entity.ViewRaceShosaiExample;
import com.example.entity.ViewRaceShosaiMapper;
import com.view.racedata.RaceShosaiReader;

public class PckeibaViewer implements Serializable,AutoCloseable{

	/**
	 *
	 */
	private static final long serialVersionUID = 1L;
	RaceShosaiReader reder;
	private ViewRaceShosaiMapper mapper;
	private ViewRaceShosaiExample example;

	public PckeibaViewer() throws IOException {
		reder = new RaceShosaiReader();
		mapper = reder.getMapper();
		example = reder.getExample();
	}

	@Override
	public void close() throws Exception {
		reder.close();
	}
	
	

}
