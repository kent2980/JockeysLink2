package com.util;

public class UtilClass {
	/**
     * <p>[概 要] 戻り値の型に合わせてキャスト</p>
     * <p>[詳 細] </p>
     * <p>[備 考] </p>
     */
	@SuppressWarnings("unchecked")
	public static <T> T AutoCast(Object obj){
		T castObj = (T) obj;
		return castObj;
	}

}
